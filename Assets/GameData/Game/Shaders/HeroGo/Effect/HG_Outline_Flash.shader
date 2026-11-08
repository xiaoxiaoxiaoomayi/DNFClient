// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// HeroGo shader base include
// (c) 2016, Simon King
Shader "Hidden/HeroGo/OutLineFlash"
{
	Properties
	{
		//Z CORRECT
		[HideInInspector]_ZSmooth("Z Correction", Range(-3.0,3.0)) = 0.5
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		//Outline Const Size - Z Correct
		Pass
		{
			Name "OUTLINE_FLASH"

			Lighting Off
			Fog{ Mode Off }
			ZWrite On
			ZTest On
			Tags{ "LightMode" = "ForwardBase" }

			Stencil
			{
				Ref 1
				Comp Greater
				Pass IncrSat
				ZFail Keep
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : normal;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float factor : TEXCOORD;
			};

			half _Outline;
			half _ZSmooth;
			uniform fixed4 _OutlineColorBegin;
			uniform fixed4 _OutlineColorEnd;

			half _FlashFreq;
			half _ElapsedTime;
			float4 _WorldRefPos;

			v2f vert(a2v v)
			{
				v2f o;
				o.factor.x = 0.5 * sin(_ElapsedTime * _FlashFreq * 3.1415926) + 0.5;
				float4 pos = v.vertex + float4(normalize(v.normal), 0) * _Outline;

				o.pos = UnityObjectToClipPos(pos);

				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				half4 color = lerp(_OutlineColorEnd,_OutlineColorBegin,IN.factor.x);
				return color;
			}
			ENDCG
		}
	}
	Fallback Off
}

