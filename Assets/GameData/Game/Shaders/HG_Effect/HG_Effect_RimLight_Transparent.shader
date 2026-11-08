// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// HeroGo shader base include

Shader "HeroGo/Effect/RimLight_Transparent"
{
	Properties
	{
		_Albedo("Albedo (RGB)", 2D) = "white" {}

		//OUTLINE
		_RimPow("Rim Pow", Range(1, 5)) = 2
		_RimFactor("Rim Factor",Range(0, 2)) = 0.1
		_RimColor("Rim Color", Color) = (1.0, 0.0, 0.0, 1)
		_Intensity("Intensity",Range(1, 5)) = 1
		_Opacity("Opacity",Range(0, 1)) = 1
	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"Queue" = "Transparent"
			"RenderType" = "Transparent"

		}
		Blend SrcAlpha One
       // Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			Name "EFFECT_RIMLIGHT"

			ZWrite Off
			//ZTest On
		
			Cull Back
			Lighting Off

			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "../HG_PBR/Inc/hg_base.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv_MainTex		: TEXCOORD0;
				float3 WorldNormal		: TEXCOORD2;
				float3 ViewDir			: TEXCOORD3;

				float4 HPosition		: SV_POSITION;
			};

			half _RimPow;
     		half _RimFactor;
        	half3 _RimColor;
			half _Intensity;
			half _Opacity;
        
			float4 _Albedo_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				o.WorldNormal = normalize(mul(unity_ObjectToWorld, real4(v.normal, 0)));

				float3 WorldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				//float3 camPos = float3(UNITY_MATRIX_V[0].w, UNITY_MATRIX_V[1].w, UNITY_MATRIX_V[1].w);
				//float3 camPos = _WorldSpaceCameraPos;
				o.ViewDir = normalize(_WorldSpaceCameraPos - WorldPosition);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _Albedo);

				return o;
			}

			sampler2D _Albedo;

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_Albedo, IN.uv_MainTex) * _Intensity;
				real3 Nn = IN.WorldNormal;
			
				// Compute view direction.
				float3 Vn = normalize(IN.ViewDir);

				// Outline flash
				fixed4 col = albedo;//albedo;
				real fresnel = 1.0 - saturate(dot(Nn, Vn));
	
				col.rgb += pow(fresnel, _RimPow) *_RimColor * _RimFactor;
				col.a =  _Opacity;

				return col;
			}
			ENDCG
		}
	}
}