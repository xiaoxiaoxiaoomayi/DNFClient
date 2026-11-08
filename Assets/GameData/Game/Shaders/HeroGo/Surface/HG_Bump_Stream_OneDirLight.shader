// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/General/OneDirLight/Bumped_Stream"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_TintMap("Glossy (RGB) R:Metallic G:Smoothness", 2D) = "gray" {}
		_LitSphere("Lit Sphere (RGB)", 2D) = "gray" {}

		_LightIntensity("Light Intensity",Range(0, 5)) = 2
		_LightAttenurate("Light Attenurate",Range(0, 1)) = 0.1
		_ReflectionIntensity("Reflection Intensity",Range(0, 1)) = 0.5
		_AmbientIntensity("Ambient Intensity",Range(0, 1)) = 0.5
		_FresnelPow("Fresnel Pow",Range(1, 6)) = 3
		_FresnelFactor("Fresnel Factor",Range(0, 1)) = 0.1
		_FresnelOffset("Fresnel Color Offset",Range(0, 1)) = 0.5

		//_Metallic("Metallic",Range(0, 1)) = 0.5
		//_Roughness("Roughness",Range(0, 1)) = 0.5
		_Modify_Color("Tint Color",Color) = (1,1,1,1)

		_StreamMap("Stream Map(RGB)", 2D) = "white" {}
		_SpeedUV("Stream Speed UV",Vector) = (0.1,0.1,0,0)
		_StreamColor("Stream Color(Stream color)",Color) = (1.0,1.0,1.0,1.0)

		//[HideInInspector]_ElapsedTime("Elapsed time", Range(0, 6)) = 0.0
		//_ElapsedTime("Elapsed time", Range(0, 6)) = 0.0
	}

	SubShader
	{
		Tags{ "IgnoreProjector" = "True" "RenderType" = "Opaque" }

		Pass
		{
			Name "BUMPED_STREAM"

			Cull Back
			Lighting Off
			ZWrite On

			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "../../HG_PBR/Inc/hg_brdf.cginc"
			 
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
				float3 WorldPosition	: TEXCOORD2;
				float3 WorldNormal		: TEXCOORD3;
				float3 WorldTangent		: TEXCOORD4;
				float3 WorldBinormal	: TEXCOORD5;
				float3 ViewDir			: TEXCOORD6; 

				float4 HPosition		: SV_POSITION;
			};

			sampler2D _MainTex; /// Albedo
			sampler2D _BumpMap; /// Bump
			sampler2D _TintMap;    /// Ramp
			sampler2D _LitSphere;    /// Ramp
			float4 _MainTex_ST;

			real4 _LightColor;
			real _LightIntensity;
			real _LightAttenurate;
			real _ReflectionIntensity;
			real _AmbientIntensity;

			real4 _Modify_Color;

			sampler2D _StreamMap; /// Stream
			half2 _SpeedUV;
			fixed4 _StreamColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				half3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.WorldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.WorldNormal = normalize(mul(unity_ObjectToWorld, real4(v.normal, 0)));
				o.WorldTangent = normalize(mul(unity_ObjectToWorld, real4(v.tangent.xyz, 0)));
				o.WorldBinormal = normalize(mul(unity_ObjectToWorld, real4(binormal, 0)));

				//float3 camPos = float3(UNITY_MATRIX_V[0].w, UNITY_MATRIX_V[1].w, UNITY_MATRIX_V[1].w);
				//float3 camPos = _WorldSpaceCameraPos;
				o.ViewDir = normalize(_WorldSpaceCameraPos - o.WorldPosition);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o, o.HPosition);

				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);

				/// Nn map
				real3 bump = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
				real3 Nn = IN.WorldNormal;
				real3 Tn = IN.WorldTangent;
				real3 Bn = IN.WorldBinormal;
				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);

				float3 LightD = IN.ViewDir;
				real3 Ln = normalize(LightD);
				float LightDist = length(LightD);

				real4 glossy = tex2D(_TintMap, IN.uv_MainTex);
				//real metallic = lerp(glossy.x, _Metallic - 0.0001f, _MetallicFactor);
				//real roughness = lerp(1 - glossy.y, _Roughness - 0.0001f, _RoughnessFactor);
				real metallic = glossy.x;//_Metallic;//
				real roughness = 1 - glossy.y;//_Roughness;//

				// Compute view direction.
				float3 Vn = normalize(IN.ViewDir);

				// Lerp with metallic value to find the good diffuse and specular.
				float3 realAlbedo = albedo - albedo * metallic;

				// 0.03 default specular value for dielectric.
				float3 realSpecularColor = lerp(0.03f, albedo, metallic);

				float3 light1 = compute_brdf(realAlbedo, realSpecularColor, _LightColor0, Nn, roughness, Ln, Vn);

				float attenuation = PI / (LightDist * LightDist);
				float mipIndex = roughness * roughness * 64.0f;

				float3 envColor = tex2Dlod(_LitSphere, real4(get_envmap_uv_cylindrical(-Vn, Nn, 1),1,mipIndex));

				fixed3 fresnelCol = realSpecularColor * envColor * (1 - metallic);
				fixed3 envFresnel = max(spec_fresnel_roughness(fresnelCol, roughness * roughness, Nn, Vn), glossy.z*spec_fresnel_assistant_light(fresnelCol, Nn, Vn, dot(float3(Vn.z, Vn.y, -Vn.x), Nn)));

				real4 col;
				col.rgb = _LightIntensity * light1 + realAlbedo * _AmbientIntensity + envFresnel * envColor * _ReflectionIntensity;

				real3 tintMask = (saturate((glossy.a - (1.0f - _Modify_Color.rgb) / glossy.a)));
				col.rgb = col.rgb * (1 - glossy.a * 0.8) + col.rgb * tintMask;

				half2 uv = IN.uv_MainTex + _SpeedUV.xy * _Time.y;
				fixed4 stream = tex2D(_StreamMap, uv);

				col.rgb = col.rgb + stream.rgb * stream.rgb * stream.rgb * _StreamColor.rgb * _StreamColor.a * 2.0f;
				col.a = albedo.a * _Modify_Color.a;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}






