// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/General/UnLit/HG_UnLit_Dye_BlackHole"
{
	Properties
	{
		_MainValue ("MainValue", Range(0, 1)) = 0.3
        [MaterialToggle] _InvertAlpha ("Invert Alpha", Float ) = 0
		_offsetX("Offset X",Float) = 0
		_offsetY("Offset Y",Float) = 0
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_noiseTex ("Noise Tex", 2D) = "white" {}
		_DyeColor("Dye color",Color) = (1.0,1.0,1.0,1.0)
		_ColorStrength("Color Strength",Range(0, 1)) = 0.3
		[HideInInspector]_AlphaFactor("Alpha factor",Range(0,1)) = 0.5
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" 
		"IgnoreProjector" = "True" 
		"RenderType" = "Transparent-1" }
		LOD 100

		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "../../Includes/TMShaderSupport.cginc"

			fixed _InvertAlpha;
             fixed _MainValue;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _DyeColor;
			fixed _AlphaFactor;
			half _ColorStrength;
			sampler2D _noiseTex;  
			float4 _noiseTex_ST;
			 fixed _offsetX;
			 fixed _offsetY;

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float4 projPos : TEXCOORD1;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.projPos = ComputeScreenPos (o.vertex);
                COMPUTE_EYEDEPTH(o.projPos.z);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 sceneUVs = i.projPos.xy / i.projPos.w;
				sceneUVs = float2(sceneUVs.r * 1.778 - 0.4 + _offsetX, sceneUVs.g + _offsetY);
				float rotator_cos = -0.128844;
                float rotator_sin = -0.991665;
                float2x2 rotatorM = float2x2(rotator_cos, -rotator_sin, rotator_sin, rotator_cos);
                float2 rotator = mul(sceneUVs - float2(0.5, 0.5), rotatorM) + float2(0.5, 0.5);
                float centerMask = length(sceneUVs * 2.0 - 1.0);
                float2 uVx2 = lerp(sceneUVs, rotator, centerMask) * 2.0 - 1.0;
                float2 AppUV_02 = float2((((atan2(uVx2.r, uVx2.g) * 0.159) + 0.5) * 3.0) + _MainValue,centerMask + (1.0 - _Time.r));
                fixed4 invert = tex2D(_noiseTex, TRANSFORM_TEX(AppUV_02, _noiseTex));
                fixed centreMask = invert.r * centerMask + centerMask * 0.7;
                fixed startPoint = _MainValue * 4.0 - 0.3;
				fixed centreMaskResult = saturate((centreMask - startPoint) * 3.333);
                fixed invertAlphaVar = lerp( centreMaskResult, (1.0 - centreMaskResult), _InvertAlpha );
                fixed edgeOr = abs(invertAlphaVar - 0.5) * 2.0;
                fixed3 hiLightEdge = lerp(fixed3(1, 1, 0), fixed3(1, 0, 0),(edgeOr * 2.0));
                fixed4 mainTexVar = tex2D(_MainTex, i.texcoord);
                fixed3 finalColor = lerp(hiLightEdge, mainTexVar.rgb, edgeOr);
                fixed4 final = fixed4(finalColor,min(mainTexVar.a,max(invertAlphaVar,(1.0 - edgeOr))));
				
				fixed4 col = final * _DyeColor;
				col.rgb = lerp(col.rgb, col.rgb * SafeNormalize(col.rgb), _ColorStrength);
				col.a *= _AlphaFactor;

				return col;
			}

			ENDCG
		}
	}

}
