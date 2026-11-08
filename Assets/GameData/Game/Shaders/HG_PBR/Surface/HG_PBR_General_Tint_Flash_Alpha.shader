// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/PBR/Surface/Tint_Flash_Alpha"
{
	Properties
	{
		_Albedo("Albedo (RGB)", 2D) = "white" {}
		_Bump("Bump (RGB)", 2D) = "white" {}
		_Param("Glossy (RGB) R:Metallic G:Smoothness", 2D) = "gray" {}
		_LitSphere("Lit Sphere (RGB)", 2D) = "gray" {}

		_LightIntensity("Light Intensity",Range(0, 5)) = 2
		_LightAttenurate("Light Attenurate",Range(0, 1)) = 0.1
		_ReflectionIntensity("Reflection Intensity",Range(0, 1)) = 0.5
		_AmbientIntensity("Ambient Intensity",Range(0, 1)) = 0.5
		_FresnelPow("Fresnel Pow",Range(1, 6)) = 3
		_FresnelFactor("Fresnel Factor",Range(0, 1)) = 0.1
		_FresnelOffset("Fresnel Color Offset",Range(0, 1)) = 0.5

		_TintColor("Tint Color",Color) = (0.8,0.0,0.0,1.0)
		_TintFactorUpper("Tint Degree Upper",Range(0, 1)) = 0.5
		_TintFactorLower("Tint Degree Lower",Range(0, 1)) = 0.5
		_TintFreq("Tint Freq",Range(0, 20)) = 2

		[HideInInspector]_ElapsedTime("Elapsed time", Float) = 0.0
	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		LOD 100

		Pass
		{
			Name "PBR_SURFACE_TINT_FLASH_ALPHA"

			Cull Back
			Lighting Off
			ZWrite On

			Blend SrcAlpha OneMinusSrcAlpha

			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "../Inc/hg_brdf.cginc"

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
				float TintFactor : TEXCOORD7;

				float4 HPosition		: SV_POSITION;
			};

			float4 _Albedo_ST;

			real _TintFactorUpper;
			real _TintFactorLower;
			real _TintFreq;
			real4 _TintColor;
			real _ElapsedTime;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				o.WorldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				float3 normalWorld = UnityObjectToWorldNormal(v.normal);
				float3 tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
				float sign = v.tangent.w * unity_WorldTransformParams.w;
				float3 binormal = cross(normalWorld, tangentWorld) * sign;
				o.WorldTangent = tangentWorld.xyz;
				o.WorldBinormal = binormal;
				o.WorldNormal = normalWorld;

				//float3 camPos = float3(UNITY_MATRIX_V[0].w, UNITY_MATRIX_V[1].w, UNITY_MATRIX_V[1].w);
				//float3 camPos = _WorldSpaceCameraPos;
				o.ViewDir = normalize(_WorldSpaceCameraPos - o.WorldPosition);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _Albedo);

				o.TintFactor = saturate((_TintFactorUpper - _TintFactorLower) * (0.5 * sin(_ElapsedTime * _TintFreq * 3.1415926) + 0.5) + _TintFactorLower);

				UNITY_TRANSFER_FOG(o, o.HPosition);

				return o;
			}

			sampler2D _Albedo;
			sampler2D _Bump;
			sampler2D _Param;
			sampler2D _LitSphere;

			real4 _LightColor;
			real _LightIntensity;
			real _LightAttenurate;
			real _ReflectionIntensity;
			real _AmbientIntensity;

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_Albedo, IN.uv_MainTex);

				/// Nn map
				real3 bump = UnpackNormal(tex2D(_Bump, IN.uv_MainTex));
				real3 Nn = IN.WorldNormal;
				real3 Tn = IN.WorldTangent;
				real3 Bn = IN.WorldBinormal;
				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);

				float3 LightD = IN.ViewDir;
				real3 Ln = normalize(LightD);
				float LightDist = length(LightD);

				real4 glossy = tex2D(_Param, IN.uv_MainTex);
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

				//float3 envColor = tex2D(_LitSphere, get_envmap_uv_cylindrical(-Vn, Nn, 1));

				fixed3 fresnelCol = realSpecularColor * 0.5 * (1 - metallic);
				fixed3 envFresnel = spec_fresnel_roughness(fresnelCol, roughness * roughness, Nn, Vn);//max(spec_fresnel_roughness(fresnelCol, roughness * roughness, Nn, Vn), glossy.z*spec_fresnel_assistant_light(fresnelCol, Nn, Vn, dot(float3(Vn.z, Vn.y, -Vn.x), Nn)));

				//return float4(envFresnel*envColor, 1) * (1-metallic);
				//return float4((envFresnel * 1 * _ReflectionIntensity).xxx, 1.0f);

				real4 col;
				col.rgb = _LightIntensity * light1 + realAlbedo * _AmbientIntensity + envFresnel * 0.5f * _ReflectionIntensity;

				// Tint color flash phase
				col.rgb = lerp(col.rgb, _TintColor.rgb, saturate(IN.TintFactor));
				col.a = albedo.a;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "HeroGo/PBR/Surface/General"
}
