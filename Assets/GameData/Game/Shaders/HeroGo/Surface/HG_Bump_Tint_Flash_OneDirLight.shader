// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Shader "HeroGo/General/OneDirLight/Bumped_Tint_Flash"
//{	
//	Properties
//	{
//		_MainTex("Albedo (RGB)", 2D) = "white" {}
//		_BumpMap("Bump (RGB)", 2D) = "white" {}
//		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}
//
//		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
//		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)
//
//		_TintColor("Tint Color",Color) = (0.8,0.0,0.0,1.0)
//		_TintFactorUpper("Tint Degree Upper",Range(0, 1)) = 0.5
//		_TintFactorLower("Tint Degree Lower",Range(0, 1)) = 0.5
//		_TintFreq("Tint Freq",Range(0, 10)) = 2
//
//		[HideInInspector]_ElapsedTime("Elapsed time", Range(0, 1)) = 0.0
//	}
//
//	SubShader
//	{
//		Tags{ "RenderType" = "Opaque" }
//		LOD 200
//
//		CGPROGRAM
//		#include "../Inc/Toon.cginc"
//
//		/// nolightmap nodirlightmap		LIGHTMAP
//		/// noforwardadd					ONLY 1 DIR LIGHT (OTHER LIGHTS AS VERTEX-LIT)
//		#pragma surface surf Cartoon nolightmap nodirlightmap noforwardadd finalcolor:final
//		/// Use shader model 3.0 target, to get nicer looking lighting
//		/// #pragma target 3.0
//
//		sampler2D _MainTex; /// Albedo
//		sampler2D _BumpMap; /// Bump
//
//		half _TintFactorUpper;
//		half _TintFactorLower;
//		half _TintFreq;
//		uniform fixed4 _TintColor;
//		half _ElapsedTime;
//
//		struct Input
//		{
//			float2 uv_MainTex : TEXCOORD0;
//			float2 uv_BumpMap : TEXCOORD1;
//		};
//
//		void surf(Input IN, inout SurfaceOutput o)
//		{
//			/// Albedo comes from a texture tinted by color
//			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
//			/// Normal map
//			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
//		}
//
//		void final(Input IN, SurfaceOutput o, inout fixed4 color)
//		{
//			color.rgb = color.rgb * color.a;
//			half scale = _TintFactorUpper - _TintFactorLower;
//			color.rgb = lerp(color.rgb, _TintColor, scale * ( 0.5 * sin(_ElapsedTime * _TintFreq * 3.1415926) + 0.5) + _TintFactorLower);
//		}
//
//		ENDCG
//	}
//	FallBack "HeroGo/General/OneDirLight/Bumped_Tint"
//}

Shader "HeroGo/General/OneDirLight/Bumped_Tint_Flash"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)

		_TintColor("Tint Color",Color) = (0.8,0.0,0.0,1.0)
		_TintFactorUpper("Tint Degree Upper",Range(0, 1)) = 0.5
		_TintFactorLower("Tint Degree Lower",Range(0, 1)) = 0.5
		_TintFreq("Tint Freq",Range(0, 20)) = 2

		[HideInInspector]_ElapsedTime("Elapsed time", Range(0, 1)) = 0.0
	}

	SubShader
	{
		Tags{ "IgnoreProjector" = "True" "RenderType" = "Opaque" }

		Pass
		{
			Name "BUMPED_TINT_FLASH"
			LOD 100
			Cull Back
			Lighting Off
			ZWrite On

			Fog{ Mode Off }
			//Blend SrcAlpha OneMinusSrcAlpha

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
				float4 viewDir			: TEXCOORD5;

				float4 HPosition		: SV_POSITION;
			};

			sampler2D _MainTex; /// Albedo
			sampler2D _BumpMap; /// Bump
			sampler2D _Ramp;    /// Ramp
			float4 _MainTex_ST;

			fixed4 _ShadowColor;
			fixed4 _LittenColor;

			half _TintFactorUpper;
			half _TintFactorLower;
			half _TintFreq;
			uniform fixed4 _TintColor;
			half _ElapsedTime;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				half3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.WorldNormal = mul(unity_ObjectToWorld, real4(v.normal, 0));
				o.WorldTangent = mul(unity_ObjectToWorld, real4(v.tangent.xyz, 0));
				o.WorldBinormal = mul(unity_ObjectToWorld, real4(binormal, 0));

				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);

				o.viewDir.xyz = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.viewDir.w = saturate((_TintFactorUpper - _TintFactorLower) * (0.5 * sin(_ElapsedTime * _TintFreq * 3.1415926) + 0.5) + _TintFactorLower);

				UNITY_TRANSFER_FOG(o,o.HPosition);

				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);

				/// Normal map
				real3 bump = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));

				real3 Nn = normalize(IN.WorldNormal);
				real3 Tn = normalize(IN.WorldTangent);
				real3 Bn = normalize(IN.WorldBinormal);

				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);

				fixed4 col = toon_term(_Ramp, _WorldSpaceLightPos0.xyz, Nn, albedo, _ShadowColor, _LittenColor);

				col.rgb = col.rgb;
				col.rgb = lerp(col.rgb, _TintColor, IN.viewDir.w);
				col.a = albedo.a;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}






