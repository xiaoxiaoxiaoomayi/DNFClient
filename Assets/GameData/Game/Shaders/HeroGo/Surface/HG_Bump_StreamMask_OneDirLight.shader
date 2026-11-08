// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/General/OneDirLight/Bumped_Stream_Mask"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_ParamMap("Param (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)

		_StreamMap("Stream Map(RGB)", 2D) = "white" {}
		_SpeedUV("Stream Speed UV",Vector) = (0.1,0.1,0,0)

		//[HideInInspector]_ElapsedTime("Elapsed time", Range(0, 6)) = 0.0
		//_ElapsedTime("Elapsed time", Range(0, 6)) = 0.0
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		Pass
		{
			Name "BUMPED_STREAM_MASK"
			LOD 100
			Cull Back
			Lighting Off
			ZWrite On

			Fog{ Mode Off }
			Blend SrcAlpha OneMinusSrcAlpha

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
			sampler2D _ParamMap; /// Param
			sampler2D _Ramp;    /// Ramp
			float4 _MainTex_ST;

			sampler2D _StreamMap; /// Stream
			half2 _SpeedUV;

			fixed4 _ShadowColor;
			fixed4 _LittenColor;

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

				o.viewDir.w = 1;//1 - saturate(max(_ElapsedTime - _FadeOutBegin, 0) / _FadeOutLen);

				UNITY_TRANSFER_FOG(o,o.HPosition);

				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
				fixed4 param = tex2D(_ParamMap, IN.uv_MainTex);

				/// Normal map
				real3 bump = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));

				real3 Nn = normalize(IN.WorldNormal);
				real3 Tn = normalize(IN.WorldTangent);
				real3 Bn = normalize(IN.WorldBinormal);

				Nn = Nn * bump.z + bump.x * Tn + bump.y * Bn;
				Nn = normalize(Nn);

				fixed4 col = toon_term(_Ramp, _WorldSpaceLightPos0.xyz, Nn, albedo, _ShadowColor, _LittenColor);

				half2 uv = IN.uv_MainTex + _SpeedUV.xy * _Time.y;
				fixed4 stream = tex2D(_StreamMap, uv);

				col.rgb = col.rgb + stream.rgb * stream.rgb * 2 * param.r;
				col.a = IN.viewDir.w;

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}






