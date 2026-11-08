// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/General/OneDirLight/Bumped_Outline_Flash"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)

		_DummyLightDir("Virtual light direction",Vector) = (0.707,0.707,0,0)
		_LightExposure("Light exposure",Range(0.5, 2)) = 1

		_FlashFreq("Flash frequncy", Range(0, 10)) = 3
		//OUTLINE
		_Outline("Outline Width", Range(0.0, 0.1)) = 0.001
		_OutlineColorBegin("Begin Outline Color", Color) = (1.0, 0.0, 0.0, 1)
		_OutlineColorEnd("End Outline Color", Color) = (1.0, 1.0, 0.0, 1)

		[HideInInspector]_ElapsedTime("Elapsed time", Float) = 0
		[HideInInspector]_WorldRefPos("World ref position",Vector) = (0,0,0,0)
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
			Name "BUMPED_OUTLINE_FLASH"

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
			#include "../Inc/Base.cginc"

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
				float3 WorldNormal		: TEXCOORD2;
				float3 WorldTangent		: TEXCOORD3;
				float3 WorldBinormal	: TEXCOORD4;
				float3 WorldViewDir		: TEXCOORD5;
				float  Factor : TEXCOORD6;

				float4 HPosition		: SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _Ramp;
			float4 _MainTex_ST;

			fixed4 _ShadowColor;
			fixed4 _LittenColor;

			real3 _DummyLightDir;
			real _LightExposure;

			half _Outline;
			half _ZSmooth;
			uniform fixed4 _OutlineColorBegin;
			uniform fixed4 _OutlineColorEnd;

			half _FlashFreq;
			half _ElapsedTime;
			float4 _WorldRefPos;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				half3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.WorldNormal = mul(unity_ObjectToWorld, real4(v.normal,0));
				o.WorldTangent = mul(unity_ObjectToWorld, real4(v.tangent.xyz, 0));
				o.WorldBinormal = mul(unity_ObjectToWorld, real4(binormal, 0));

				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);

				o.WorldViewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.Factor.x = 0.5 * sin(_ElapsedTime * _FlashFreq * 3.1415926) + 0.5;
				UNITY_TRANSFER_FOG(o,o.HPosition);

				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);

				/// Normal map
				real3 bump = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
				//real3 bump = 2.0f * tex2D(_BumpMap, IN.uv_MainTex) -1.0f;
				//bump.y = -bump.y;

				real3 Nn = normalize(IN.WorldNormal);
				real3 Tn = normalize(IN.WorldTangent);
				real3 Bn = normalize(IN.WorldBinormal);

				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);
				real3 Vn = IN.WorldViewDir;

				//fixed4 col = toon_term(_Ramp, normalize(_DummyLightDir.xyz), Nn, albedo, _ShadowColor, _LittenColor);
				fixed4 col = toon_term(_Ramp, normalize(_WorldSpaceLightPos0.xyz), Nn, albedo, _ShadowColor, _LittenColor);
				col.rgb *= _LightExposure;

				// Outline flash
				half4 outlineCol = lerp(_OutlineColorEnd, _OutlineColorBegin, IN.Factor.x);
				real fresnel = 1.0 - saturate(dot(Nn, Vn));
				col.rgb += pow(fresnel, 2) * outlineCol * 3;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}
