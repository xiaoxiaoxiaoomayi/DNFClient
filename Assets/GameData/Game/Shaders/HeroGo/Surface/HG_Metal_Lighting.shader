// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/Surface/Metal"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_EnvMap("Env Ramp (RGB)", 2D) = "gray" {}

		_SpecualrFactor("Specualr Factor",Range(0.5, 2)) = 1
		_FresnelPow("Specualr Pow",Range(0, 16)) = 1
		_FresnelFactor("Specualr Factor",Range(0, 2)) = 1

		_LightIntensity("Specular Intensity",Range(0, 2)) = 1
		_AmbientIntensity("Ambient Intensity",Range(0, 1)) = 0.5
		_ReflectionIntensity("Reflection Intensity",Range(0, 1)) = 0.5
		_Metallic("Metallic",Range(0, 1)) = 0.5
		_Roughness("Roughness",Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"RenderType" = "Opaque"
		}
		LOD 100

		Pass
		{
			Name "METAL"

			Cull Back
			Lighting Off
			ZWrite On

			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma target 3.0
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "../Inc/Base.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv_MainTex		: TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 WorldNormal		: TEXCOORD2;
				float3 WorldTangent		: TEXCOORD3;
				float3 WorldBinormal	: TEXCOORD4;
				float3 WorldPosition	: TEXCOORD5;
				float3 WorldViewDir		: TEXCOORD6;

				float4 HPosition		: SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _EnvMap;
			float4 _MainTex_ST;

			real _Metallic;
			real _Roughness;

			real _SpecualrFactor;
			real _FresnelPow;
			real _FresnelFactor;
			real3 _FresnelColor;
			real _FresnelOffset;
			real _LightIntensity;
			real _ReflectionIntensity;
			real _AmbientIntensity;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				half3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.WorldNormal = mul(unity_ObjectToWorld, real4(v.normal,0));
				o.WorldTangent = mul(unity_ObjectToWorld, real4(v.tangent.xyz, 0));
				o.WorldBinormal = mul(unity_ObjectToWorld, real4(binormal, 0));


				o.WorldPosition = normalize(mul(unity_ObjectToWorld, v.vertex)).xyz;
				o.WorldViewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.HPosition);

				return o;
			}

			#define PI 3.1415926

			real3 Fresnel(real3 cSpecular, real3 Hn, real3 Vn)
			{
				real factor = 1.0f - saturate(dot(Vn, Hn));
				real factorPow = pow(factor, 5);
				return (cSpecular + (1.0f - cSpecular) * factorPow);
			}

			float BlinnPhong(float a, float NdH)
			{
				return (1 / (PI * a * a)) * pow(NdH, 2 / (a * a) - 2);
			}

			real3 Specular_term(real3 specularColor, real3 Hn, real3 Vn, real3 Ln, real a, real NdL, real NdV, real NdH, real VdH, real LdV)
			{
				return (BlinnPhong(a, NdH) * Fresnel(specularColor, Vn, Hn)) / (4.0f * NdL * NdV);
			}
			float3 Diffuse_term(float3 cAlbedo)
			{
				return cAlbedo / PI;
			}

			///------------------------------ Main BRDF ----------------------------------
			real3 compute_lighting(real3 cAlbedo, real3 cSpecular, real3 cLight, real3 Nn, real roughness, real3 Ln, real3 Vn)
			{
				// Compute some useful values.
				real NdL = saturate(dot(Nn, Ln)) + 0.001f;
				real NdV = saturate(dot(Nn, Vn)) + 0.001f;
				real3 Hn = normalize(Ln + Vn);
				real NdH = saturate(dot(Nn, Hn));
				real VdH = saturate(dot(Vn, Hn));
				real LdV = saturate(dot(Ln, Vn));

				real a = max(0.001f, roughness * roughness);

				real3 cDiff = Diffuse_term(cAlbedo);
				real3 cSpec = Specular_term(cSpecular, Hn, Vn, Ln, a, NdL, NdV, NdH, VdH, LdV);

				return cLight * NdL * (cDiff * (1.0f - cSpec) + cSpec);
			}

			real2 get_envmap(in real3 vView, in real3 vNormal)
			{
				real3 r = reflect(vView, vNormal);
				real m = 2. * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
				real2 uv = r.xy / m + .5;
				return uv;
			}

			float3 Roughness(float3 s, float a, float3 h, float3 v)
			{
				return (s + (max(1.0f - a, s) - s) * pow((1 - saturate(dot(v, h))), 5));
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);

				/// Normal map
				real3 bump = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
				//real3 bump = 2.0f * tex2D(_BumpMap, IN.uv_MainTex) -1.0f;
				//bump.y = -bump.y;

				real3 Nn = normalize(IN.WorldNormal);
				real3 Tn = normalize(IN.WorldTangent);
				real3 Bn = normalize(IN.WorldBinormal);

				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);
				real3 Vn = IN.WorldViewDir;

				/// PBR
				float3 LightD = _WorldSpaceLightPos0.xyz - IN.WorldPosition;
				real3 Ln = normalize(LightD);
				float LightDist = length(LightD);

				real metallic =  _Metallic - 0.0001f;
				real roughness = _Roughness - 0.0001f;

				// Lerp with metallic value to find the good diffuse and specular.
				float3 realAlbedo = albedo - albedo * metallic;

				// 0.03 default specular value for dielectric.
				float3 realSpecularColor = lerp(0.03f, albedo, metallic);

				float3 light1 = compute_lighting(realAlbedo, realSpecularColor, _LightColor0, Nn, roughness, Ln, Vn);

				float attenuation = PI / (LightDist * LightDist);
				float mipIndex = roughness * roughness * 64.0f;

				float3 envColor = tex2Dlod(_EnvMap, real4(get_envmap(-Vn, Nn), 1, mipIndex));
				float3 envFresnel = Roughness(realSpecularColor, roughness * roughness, Nn, Vn);

				real4 col = 0;
				col.rgb = _LightIntensity * light1 + realAlbedo * _AmbientIntensity + envFresnel * envColor * _ReflectionIntensity;
				col.a = albedo.a;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
