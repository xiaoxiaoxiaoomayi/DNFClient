// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// HeroGo shader base include
// (c) 2016, Simon King
Shader "Hidden/HeroGo/BackSurfaceOutLine"
{
	Properties
	{
	}
	  
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		//Outline Const Size - Z Correct
		Pass
		{
			Name "BACKSURFACE_OUTLINE"

			Lighting Off
			Fog{ Mode Off }
			Cull Front
			ZWrite On
			ZTest On
			Stencil
			{
				Ref 1
				Comp Greater
				Pass IncrSat
				ZFail Keep
			}
			Tags { "LightMode"="ForwardBase" }
			
		 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 HPosition		: SV_POSITION;
				float2 uv_MainTex		: TEXCOORD0;
			};
			 
			sampler2D _Albedo;
			
			v2f vert(a2v v)
			{
				v2f o;

				float4 pos = mul(unity_ObjectToWorld, v.vertex);
				float3 nor = mul((float3x3)unity_ObjectToWorld, v.normal).xyz;
				pos.xyz += nor * 0.009f;
				o.HPosition = mul(UNITY_MATRIX_VP, pos);
				o.uv_MainTex = v.uv;
				 
				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				fixed4 albedo = tex2D(_Albedo, IN.uv_MainTex);
				half4 color = 0.9f * albedo;
				return color;
			}
			ENDCG
		}
	}
	Fallback Off
}

