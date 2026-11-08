// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// HeroGo shader base include
// (c) 2016, Simon King
//Shader "Hidden/HeroGo/OutLine_Downgrade"
Shader "Hidden/HeroGo/OutLine_Downgrade"
{
	Properties
	{
		//OUTLINE
		// _FlashFreq("Flash frequncy", Range(0, 10)) = 3
		// _ScaleWidth("Scale width", Range(1, 10)) = 3.5
		// _BeginScale("Begin Scale", Range(0, 10)) = 3
		// _Outline("Outline Width", Range(0.0, 0.1)) = 0.001
		// _OutlineColorBegin("Begin Outline Color", Color) = (1.0, 0.0, 0.0, 1)
		// _OutlineColorEnd("End Outline Color", Color) = (1.0, 1.0, 0.0, 1)
		// _ScaleTimeLen("Scale time length", Range(0, 10)) = 0.23333331
		// 
		// _ElapsedTime("Elapsed time", Float) = 0
		// [HideInInspector]_WorldRefPos("World ref position",Vector) = (0,0,0,0)
		//Z CORRECT
		[HideInInspector]_ZSmooth("Z Correction", Range(-3.0,3.0)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"RenderType" = "Opaque"
		}
		LOD 200
		//Outline Const Size - Z Correct
		Pass
		{
			Name "OUTLINE_DOWNGRADE"

			Cull Back
			Lighting Off
			Fog{ Mode Off }
			//ZTest On
			Blend SrcAlpha One
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float2 factor : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 ViewDir : TEXCOORD2;
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
				 o.ViewDir = normalize(_WorldSpaceCameraPos - pos);
				 
				 pos.xyz -= _WorldRefPos;
				 pos.xyz *= (1.005 + o.factor.x * _BeginScale * half3(_ScaleWidth, 1, _ScaleWidth));
				 pos.xyz += _WorldRefPos;				
				 pos = mul(UNITY_MATRIX_V, pos);
				 
				 float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				 normal.z = _ZSmooth;
				 
				 //Camera-independent size
				 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
				 
				 //pos = pos + float4(normalize(normal), 0) * _Outline * dist;
				 o.pos = mul(UNITY_MATRIX_P, pos);
				 o.normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0)));
				// v2f o;
				// 
				// o.factor.xy = saturate((_ScaleTimeLen - _ElapsedTime) / _ScaleTimeLen);
				// 
				// //v.vertex.xyz *= (1 + o.factor.x * _BeginScale * half3(1, _ScaleWidth, _ScaleWidth));
				// //Correct Z artefacts
				// 
				// float4 pos = mul(unity_ObjectToWorld, v.vertex);
				// pos.xyz -= _WorldRefPos;
				// pos.xyz *= (1 + o.factor.x * _BeginScale * half3(_ScaleWidth, 1, _ScaleWidth));
				// pos.xyz += _WorldRefPos;
				// pos = mul(UNITY_MATRIX_V, pos);
				// 
				// float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				// normal.z = _ZSmooth;
				// 
				// //Camera-independent size
				// //float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
				// //
				// //pos = pos + float4(normalize(normal), 0) * _Outline * dist;
				// o.pos = mul(UNITY_MATRIX_P, pos);

				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				// Outline flash
				half3 color = lerp(_OutlineColorEnd, _OutlineColorBegin, IN.factor.x);
				half fresnel = 1.0 - saturate(dot(IN.normal, IN.ViewDir));
				return half4( pow(fresnel, 2) * color * 2, fresnel * 2);
			}
			ENDCG
		}
	}
	Fallback Off

}

