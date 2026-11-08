// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/General/UnLit/HG_Unlit_Dye_Opaque_CC"
{
	Properties
	{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_DyeColor("Dye color",Color) = (1.0,1.0,1.0,1.0)
		//
		_Brightness("Intensity", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
		//
		_ColorStrength("Color Strength",Range(0, 1)) = 0.3
	}

	SubShader
	{
		Tags{ "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 100

		Cull Back
		ZWrite On
		ZTest On
		Blend Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "../../Includes/TMShaderSupport.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//
			half _Brightness;
			half _Saturation;
			half _Contrast;
			//
			fixed4 _DyeColor;
			half _ColorStrength;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				col.rgb *= _DyeColor.rgb;

				//brightness
				fixed3 finalColor = col.rgb * _Brightness;

				//saturation
				fixed luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);

				//contrast
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);


				col.rgb = lerp(finalColor.rgb, finalColor.rgb * SafeNormalize(finalColor.rgb), _ColorStrength);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}

}
