// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/PBR/Surface/General"
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

		//_Metallic("Metallic",Range(0, 1)) = 0.5
		//_Roughness("Roughness",Range(0, 1)) = 0.5
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
			Name "PBR_SURFACE_GENERAL"

			Cull Back
			Lighting Off
			ZWrite On
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
				ZFail Keep
			}

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

			float4 _Albedo_ST;
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
				UNITY_TRANSFER_FOG(o, o.HPosition);

				return o;
			}

			sampler2D _Albedo;
			sampler2D _Bump;
			sampler2D _Param;
			sampler2D _LitSphere;

			//real _Metallic;
			//real _Roughness;

			real4 _LightColor;
			real _LightIntensity;
			real _LightAttenurate;
			real _ReflectionIntensity;
			real _AmbientIntensity;

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 albedo = tex2D(_Albedo, IN.uv_MainTex);
				fixed4 bump = fixed4(UnpackNormal(tex2D(_Bump, IN.uv_MainTex)),0);
				
				real3 Nn = IN.WorldNormal;
				real3 Tn = IN.WorldTangent;
				real3 Bn = IN.WorldBinormal;
				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);

				fixed4 glossy = tex2D(_Param, IN.uv_MainTex);
 
				// Compute view direction.
				float3 Vn = normalize(IN.ViewDir);
				float3 LightD = IN.ViewDir;
				real3 Ln = normalize(LightD);
				float LightDist = length(LightD);
				 
				fixed4 col;
 				col.rgb = pbr_lighting_low(_LitSphere, albedo, bump, glossy, Nn, Vn, Ln, _LightColor0, LightDist, _LightIntensity, _AmbientIntensity, _ReflectionIntensity);
				col.a = albedo.a;
				 
				// apply fog 
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}

		//UsePass "Hidden/HeroGo/BackSurfaceOutLine/BACKSURFACE_OUTLINE"
	}

	FallBack "Diffuse"
}
