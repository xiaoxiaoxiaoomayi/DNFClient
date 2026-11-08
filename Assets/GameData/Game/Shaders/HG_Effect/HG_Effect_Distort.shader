// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// HeroGo shader base include
// (c) 2016, Simon King
Shader "HeroGo/Effect/Distrot"
{
	Properties
	{
		_Albedo("Albedo (RGB)", 2D) = "white" {}
		_DyeColor("Color", Color) = (1,1,1,1)

		//
		_Brightness("Intensity", Range(0, 1.5)) = 1
		_Saturation("Saturation", Range(-1, 2)) = 1
		_Contrast("Contrast", Range(-1, 2)) = 1

		_Distrot("Distrot (RGB)",2D) = "white" {}

		_Speed("Speed",Range(0,8)) = 1
		_Factor("Factor",Range(0,5)) = 0.5
		_TileSize("Tile size and direction",Vector) = (1,1,0,0)
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
			Name "EFFECT_DISTROT"

			ZWrite On		
			Cull Back
			Lighting Off
			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv_MainTex		: TEXCOORD0;
				float4 HPosition		: SV_POSITION;
			};


			float4 _Albedo_ST;
			v2f vert(appdata v)
			{
				v2f o;
				o.HPosition = UnityObjectToClipPos(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _Albedo);

				return o;
			}

			sampler2D _Albedo;
			sampler2D _Distrot;

			fixed4 _DyeColor;
			//
			half _Brightness;
			half _Saturation;
			half _Contrast;
			//
			half _Speed;
			half _Factor;
			half4 _TileSize;

			fixed4 frag(v2f IN) : SV_Target
			{
				float4 distrot = tex2D(_Distrot, IN.uv_MainTex * _TileSize.xy + _Time.x * _Speed);
				float factor = tex2D(_Albedo, IN.uv_MainTex).a;
				fixed4 albedo = tex2D(_Albedo, IN.uv_MainTex + distrot.xy * _Factor * factor * 0.1);
			
			     //brightness
				fixed3 finalColor = albedo.rgb * _Brightness;

				//saturation
				fixed luminance = 0.2125 * albedo.r + 0.7154 * albedo.g + 0.0721 * albedo.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);

				//contrast
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);

				// Outline flash
				fixed4 col = fixed4(finalColor,1.0f) * _DyeColor;//albedo;
				//col.a = 1.0f;

				return col;
			}
			ENDCG
		}
	}
}