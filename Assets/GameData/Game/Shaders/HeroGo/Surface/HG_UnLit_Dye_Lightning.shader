// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/General/UnLit/HG_Unlit_Dye_Lightning"
{
	Properties
	{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_LightTex( "Lightning Texture", 2D ) = "white"{}

		_ligInt("Lightning Intensity",Range(0,1)) = 0

		_DyeColor("Dye color",Color) = (1.0,1.0,1.0,1.0)
		_ColorStrength("Color Strength",Range(0, 1)) = 0.3
		[HideInInspector]_AlphaFactor("Alpha factor",Range(0,1)) = 1.0
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

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
				fixed LI : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _LightTex;
			fixed4 _LightTex_ST;

			fixed4 _DyeColor;
			fixed _AlphaFactor;
			half _ColorStrength;

			fixed _ligInt;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.LI = _ligInt;//LightningIntensity

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) * _DyeColor;
				fixed4 lig = tex2D(_LightTex, i.texcoord);

				col.rgb = lerp( col.rgb, lig.rgb, lig.a * i.LI );

				col.rgb = lerp(col.rgb, col.rgb * SafeNormalize(col.rgb), _ColorStrength);
				col.a *= _AlphaFactor;


				return col;
			}

			ENDCG
		}
	}

}
