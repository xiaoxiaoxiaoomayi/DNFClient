Shader "HeroGo/General/UnLit/MonoColor_Rim"
{
	Properties
	{
		_MonoColor("Mono Color",Color) = (1.0,1.0,0.0,0.0)
		_Factor("Corrode Degree",Range(0, 1)) = 0.0
		_FadeFactor("Corrode Degree",Range(0, 1)) = 0.01
		_BeginScale("Begin Scale", Range(0, 3)) = 0.1
		_RimPower("RimPower", Range(0.1, 3.0)) = 1.3
		_RimIntensity("Intensity", Range(0.1, 2)) = 1.2

		_CullMode("CullMode", Int) = 0

		[HideInInspector]_WorldRefPos("World ref position",Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		//Blend SrcAlpha OneMinusSrcAlpha
		Blend SrcAlpha One
		Cull [_CullMode]
		ZWrite off

/*		
		Stencil
		{
			Ref 0
			Comp Equal
			Pass IncrSat
			ZFail Keep
		}
*/
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			//#define SMOOTH_Z_ARTEFACTS

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float3 normal : TEXCOORD0;
				float4 ViewDir : TEXCOORD1;
			};

			half _Factor;
			half _FadeFactor;
			half _BeginScale;
			fixed4 _MonoColor;
			float4 _WorldRefPos;
			fixed _RimPower;
			fixed _RimIntensity;


			v2f vert(a2v v)
			{
				v2f o;

				half factor = 1 - (_Factor - _FadeFactor) / (1 - _FadeFactor);
				float4 pos = mul(unity_ObjectToWorld, v.vertex);
				pos.xyz -= _WorldRefPos;
				pos.xyz *= (1 + factor * _BeginScale);
				pos.xyz += _WorldRefPos;
				o.pos = mul(UNITY_MATRIX_VP, pos);


				o.normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0)));
				o.ViewDir.xyz = normalize(_WorldSpaceCameraPos - pos);
				o.ViewDir.w = factor;
				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				float rim = 1 - saturate(dot(IN.normal, IN.ViewDir));
				fixed4 o;
				o.rgb = _MonoColor * pow(rim, 1 / _RimPower) * _RimIntensity;
				o.a = IN.ViewDir.w;
				return o;

				
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
