// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/General/UnLit/MonoColor"
{
	Properties
	{
		_MonoColor("Mono Color",Color) = (1.0,1.0,0.0,0.0)
		_Factor("Corrode Degree",Range(0, 1)) = 0.0
		_FadeFactor("Corrode Degree",Range(0, 1)) = 0.01
		_BeginScale("Begin Scale", Range(0, 3)) = 0.1

		[HideInInspector]_WorldRefPos("World ref position",Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Back
		
		Stencil
		{
			Ref 0
			Comp Equal
			Pass IncrSat
			ZFail Keep
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			//		#define SMOOTH_Z_ARTEFACTS

			struct a2v
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD;
			};

			half _Factor;
			half _FadeFactor;
			half _BeginScale;
			fixed4 _MonoColor;
			float4 _WorldRefPos;

			v2f vert(a2v v)
			{
				v2f o;

				half factor = 1 - (_Factor - _FadeFactor) / (1 - _FadeFactor);
				float4 pos = mul(unity_ObjectToWorld, v.vertex);
				pos.xyz -= _WorldRefPos;
				pos.xyz *= (1 + factor * _BeginScale);
				pos.xyz += _WorldRefPos;
				//pos = mul(UNITY_MATRIX_V, pos);

				o.pos = mul(UNITY_MATRIX_VP, pos);
				o.uv = factor;

				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				fixed4 o = _MonoColor;
				//o.a = 1 - (_Factor - _FadeFactor) / (1 - _FadeFactor);
				o.a = IN.uv.x;

				return o;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
