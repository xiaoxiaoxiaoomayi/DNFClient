// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// HeroGo shader base include
// (c) 2016, Simon King
Shader "Hidden/HeroGo/OutLine"
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
			Name "OUTLINE"
			
			
			Lighting Off
			Fog{ Mode Off }
			ZWrite On
			ZTest On
			Tags { "LightMode"="ForwardBase" }
			
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
				float2 factor : TEXCOORD;
			};

			half _Outline;
			half _ZSmooth;
			uniform fixed4 _OutlineColorBegin;
			uniform fixed4 _OutlineColorEnd;

			half _ElapsedTime;
			half _BeginScale;
			half _ScaleTimeLen;
			half _ScaleWidth;
			float4 _WorldRefPos;

			v2f vert(a2v v)
			{
				v2f o;

				o.factor.xy = saturate((_ScaleTimeLen - _ElapsedTime) / _ScaleTimeLen);
				
				//v.vertex.xyz *= (1 + o.factor.x * _BeginScale * half3(1, _ScaleWidth, _ScaleWidth));
				//Correct Z artefacts

				float4 pos = mul(unity_ObjectToWorld, v.vertex);
				pos.xyz -= _WorldRefPos;
				pos.xyz *= (1 + o.factor.x * _BeginScale * half3(_ScaleWidth, 1, _ScaleWidth));
				pos.xyz += _WorldRefPos;				
				pos = mul(UNITY_MATRIX_V, pos);

				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				normal.z = _ZSmooth;

				//Camera-independent size
				float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));

				pos = pos + float4(normalize(normal), 0) * _Outline * dist;
				o.pos = mul(UNITY_MATRIX_P, pos);

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

