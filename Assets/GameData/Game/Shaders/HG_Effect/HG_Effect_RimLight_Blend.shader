// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// HeroGo shader base include
// (c) 2016, Simon King
Shader "HeroGo/Effect/RimLight_Blend"
{
	Properties
	{
		//OUTLINE
		_RimPow("Rim Pow", Range(1, 5)) = 2
		_RimFactor("Rim Factor",Range(0, 2)) = 0.1
		_RimColor("Rim Color", Color) = (1.0, 0.0, 0.0, 1)
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType" = "Transparent"
		}

		LOD 100

		Pass
		{
			Name "EFFECT_RIMLIGHT_BLEND"

			ZWrite Off
			ZTest On
		
			Cull Back
			Lighting Off
			//Blend SrcAlpha One
			Blend SrcAlpha OneMinusSrcAlpha
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
			};

			struct v2f
			{
				float3 WorldNormal		: TEXCOORD2;
				float3 ViewDir			: TEXCOORD3;

				float4 HPosition		: SV_POSITION;
			};


			half _RimPow;
     		half _RimFactor;
        	half4 _RimColor;
        
			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				o.WorldNormal = normalize(mul(unity_ObjectToWorld, real4(v.normal, 0)));

				float3 WorldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				//float3 camPos = float3(UNITY_MATRIX_V[0].w, UNITY_MATRIX_V[1].w, UNITY_MATRIX_V[1].w);
				//float3 camPos = _WorldSpaceCameraPos;
				o.ViewDir = normalize(_WorldSpaceCameraPos - WorldPosition);

				return o;
			}

			sampler2D _Albedo;

			fixed4 frag(v2f IN) : SV_Target
			{
				real3 Nn = normalize(IN.WorldNormal);
			
				// Compute view direction.
				float3 Vn = normalize(IN.ViewDir);

				// Outline flash
				real fresnel = 1.0 - saturate(dot(Nn, Vn));
	
				//col.rgba += pow(fresnel, _RimPow) *_RimColor.rgba * _RimFactor;
				//col.a *= _RimColor.a;

				fixed4 col = pow(fresnel, _RimPow) *_RimColor.rgba * _RimFactor;

				return col;
			}
			ENDCG
		}
	}
}