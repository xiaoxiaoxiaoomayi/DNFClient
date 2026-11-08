// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/General/OneDirLight/Basic"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)

		_LightExposure("Light exposure",Range(0.5, 2)) = 1
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
			Name "BASIC"

			Cull Back
			Lighting Off
			ZWrite On

			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
						// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "../Inc/Base.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv_MainTex		: TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 WorldNormal		: TEXCOORD2;

				float4 HPosition		: SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _Ramp;
			float4 _MainTex_ST;

			fixed4 _ShadowColor;
			fixed4 _LittenColor;

			real _LightExposure;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				o.WorldNormal = mul(unity_ObjectToWorld, real4(v.normal,0));

				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.HPosition);

				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
				real3 Nn = normalize(IN.WorldNormal);

				//fixed4 col = toon_term(_Ramp, normalize(_DummyLightDir.xyz), Nn, albedo, _ShadowColor, _LittenColor);
				fixed4 col = toon_term(_Ramp, normalize(_WorldSpaceLightPos0.xyz), Nn, albedo, _ShadowColor, _LittenColor);
				col.rgb *= _LightExposure;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
