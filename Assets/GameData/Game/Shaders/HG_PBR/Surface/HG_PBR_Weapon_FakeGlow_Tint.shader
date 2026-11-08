// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/PBR/Surface/Weapon_FakeGlow_Tint"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_RampMap("Ramp (RGB)", 2D) = "white" {}
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
		_Transparent("Transparent",Range(0, 1)) = 0.1
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
			Name "PBR_SURFACE_WEAPON_FAKEGLOW_TINT"

			Cull Back
			Lighting Off
			ZWrite Off
			ZTest On
			BlendOp Add
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

				float4 HPosition		: SV_POSITION;
			};

			float4 _MainTex_ST;
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
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o, o.HPosition);

				return o;
			}

			sampler2D _MainTex;
			sampler2D _RampMap;
			sampler2D _TintMap;
			sampler2D _LitSphere;

			//real _Metallic;
			//real _Roughness;

			real4 _LightColor;
			real _LightIntensity;
			real _LightAttenurate;
			real _ReflectionIntensity;
			real _AmbientIntensity;

			real _Transparent;

			real4 _Modify_Color;

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
				
				//return 0.5f + dot(IN.ViewDir,IN.WorldNormal) * 0.5f;
				real4 col;
				col = albedo;
				real4 param = tex2D(_TintMap, IN.uv_MainTex);
				real4 param1 = tex2D(_TintMap, IN.uv_MainTex + _Time.x);
				//fixed4 param = tex2D(_TintMap, IN.uv_MainTex + param1.z * _Time.y * 0.1f);

				fixed4 ramp = tex2D(_RampMap,param.x * 0.1f + (_Time.y + param1.z*1.2f) * 0.2f);
				col.xyz = param.y * ramp.xyz + (1- param.y) * albedo.xyz;
				col.a = _Transparent * param1.w * dot(IN.ViewDir, IN.WorldNormal) * 2;
				 
				// apply fog 
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
