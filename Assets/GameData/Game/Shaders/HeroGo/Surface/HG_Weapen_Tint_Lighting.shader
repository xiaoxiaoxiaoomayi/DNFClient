// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "HeroGo/Surface/Weapon"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_TintMap("Tint (RGB)", 2D) = "gray" {}

		_AmbientColor("Ambient Color",Color) = (0.55,0.55,0.55,0.55)
		_Modify_Color("Tint Color",Color) = (1,1,1,1)
		_Specular_color("Specular Color",Color) = (1,1,1,1)
		_Gloss("Specular Glossy",Range(0, 6)) = 1
		_Specular_slider("Specular Factor",Range(0, 2)) = 0.3
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
			Name "WEAPON"

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
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
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
				float3 WorldPosition	: TEXCOORD5;
				float3 WorldViewDir		: TEXCOORD6;

				float4 HPosition		: SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _TintMap;
			float4 _MainTex_ST;
			
			real4 _Modify_Color;
			real4 _Specular_color;
			real4 _AmbientColor;
			real _Gloss;
			real _Specular_slider;

			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				half3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.WorldNormal = mul(unity_ObjectToWorld, real4(v.normal,0));
				o.WorldTangent = mul(unity_ObjectToWorld, real4(v.tangent.xyz, 0));
				o.WorldBinormal = mul(unity_ObjectToWorld, real4(binormal, 0));

				o.WorldPosition = normalize(mul(unity_ObjectToWorld, v.vertex)).xyz;
				o.WorldViewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.HPosition);

				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				/// Albedo comes from a texture tinted by color
				fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
				fixed4 tintFactor = tex2D(_TintMap, IN.uv_MainTex);

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
				real3 Ln = normalize(_WorldSpaceLightPos0.xyz - IN.WorldPosition);
				real3 Hn = normalize(Vn + Ln);

				fixed4 col = 0;
				
				float attenuation = LIGHT_ATTENUATION(i);
				float3 attenColor = attenuation * _LightColor0.xyz;

				real3 tintMask = (saturate((tintFactor.a - (1.0f - _Modify_Color.rgb) / tintFactor.a)));

				float3 diffuse = saturate((dot(Nn, Ln) * 0.5 + 0.5f) * _LightColor0 + _AmbientColor.rgb) * albedo.rgb;
				float3 specularColor = (_Specular_color.rgb * tintMask);
				float3 directSpecular = saturate(pow(max(0, dot(Hn, Nn)), _Gloss * 10.0 + 1.0)) * _Specular_slider;
				col.rgb = (diffuse + directSpecular * _Specular_color) * (1 - tintFactor.a * 0.8) + (diffuse + directSpecular) * tintMask;

				col.a = 1;
				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
