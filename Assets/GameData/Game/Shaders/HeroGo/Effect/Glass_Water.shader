Shader "HeroGo/Effect/Glass_Water" {
    Properties {
		_HighlightColor ("Highlight Color", Color) = (1,1,1,1)
        _RimColor ("Rim Color", Color) = (0.5,1,1,1)
        _OutlineColor ("Outling Color", Color) = (0,0.3793104,1,1)
        _MainTexture ("Main Texture", 2D) = "white" {}
		_MaskTexture ("Mask Texture", 2D) = "white" {}
		_WaterMainColor ("Water Main Color", Color) = (0,0.5,0,1)
        _WaterHightColor ("Water Hight Color", Color) = (1,1,0,1)
        _Quantity ("Water Quantity", Range(0, 1)) = 0.5
        _Speed ("Water Speed", Range(0, 1)) = 0.5

		_CentreMaskOffsetU ("Centre Mask Offset U", Float ) = 0.016
        _CentreMaskOffsetV ("Centre Mask Offset V", Float ) = 0.068

		_sideAlpha ("Side Alpha", Range(0, 1)) = 0

        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "../Inc/GinoFunctions.cginc"
            #pragma target 2.0

            fixed4 _WaterMainColor;
            fixed4 _WaterHightColor;
            fixed _Quantity;
            sampler2D _MaskTexture;
            sampler2D _MainTexture;
            fixed4 _HighlightColor;
            fixed4 _RimColor;
            fixed4 _OutlineColor;
            float _Speed;

			fixed _CentreMaskOffsetU;
            fixed _CentreMaskOffsetV;

			fixed _sideAlpha;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                fixed4 _MainTexture_var = tex2D(_MainTexture,i.uv0);
                fixed2 UVRemap = (i.uv0 * 2.0 - 1.0);
                fixed Centre = length(UVRemap);
                fixed CentreOneMin = (1.0 - Centre);
                fixed CentreDivide = CentreOneMin * 0.7;
                fixed3 darken = _MainTexture_var.rgb - CentreDivide;
                float2 UVCompC = (i.uv0 + _Time.g * fixed2(0.5, 0)).rg;
				float2 Repetition = abs(frac(3.0 * UVCompC) - 0.5);
				fixed2 RepetitionZoom = max(Repetition.r, Repetition.g) * 0.12;
				fixed2 centreZoom = lerp(i.uv0, fixed2(0.5, 0.5), (0.7 * CentreOneMin));
				float2 bubbleInc = _Time.g * float2((_Speed * 0.25 + 0.07), -0.25);
				float2 UVMe = centreZoom + bubbleInc;
				///////Use Simple Noise
				fixed Bubble;
				SimpleNoise_float(UVMe, 40, Bubble);
				//
                float2 UVMemap = (RepetitionZoom * 0.3 + UVMe + Bubble * 0.05);


				///////Use Voronoi
			    /**/ float BubbleV;
                /**/ float Cells;
				/**/ float perturbation = _Time.g * (3/*自扰动速度*/);
                /**/ Unity_Voronoi_float(UVMemap, perturbation/*自扰动*/, 6/*缩放倍数*/, BubbleV, Cells);
				//


                fixed CentreClamp = CentreOneMin * 1.25 - 0.25;
                fixed Uabs = pow((abs(i.uv0.r - 0.5) * 2), 2);
                fixed OneMinusA = 1.0 - abs((_Quantity - 0.5) * 2);
				fixed quantityOffset = i.uv0.g + (_Quantity * -1.05 + 0.55);
				float lateral = (((abs(frac((_Time.g + i.uv0.r) * 0.4) - 0.5) * 2) - 0.5) * 2);
                float Side = quantityOffset + (Uabs * (lateral * (OneMinusA * 0.1)));
				float Arc = ((1.0 - Uabs) * ((sin(_Time.a)) * -0.05 + 0.05));
                float Mult = (Arc * (OneMinusA * 2.5 - 1.5)) * OneMinusA;
				float sinTimeB = (sin(_Time.b) * 0.015 + 0.065);
				float sinTimeG = sin((((_Time.g * (_Speed * 0.9 + 0.1)) + i.uv0.r) * 6.0));
                float RootA = ((Side + Mult) + (((sinTimeB * sinTimeG) * (1.0 - Uabs)) * OneMinusA));
                fixed CentreMask = max((RootA * 1.67), length(fixed2(UVRemap.r, (UVRemap.g + 0.45))));
				fixed2 UVOffset = fixed2(i.uv0.r,((i.uv0.g + (_Quantity * -1.4 + 0.4)) * 4.0));
                fixed2 UVCompress = (UVOffset * 2.0 - 1.0);
                float TimeRate = (_Time.g * (_Speed * 0.38 + 0.12));
				float face = (atan2(UVCompress.r, UVCompress.g) / 6.28);
				fixed Surface = (((face + 0.5) + (1.0 - TimeRate)) * 5.0);
                float2 AppendUV = fixed2(((length(UVCompress) + TimeRate) * 2), Surface);

				///////Use Simple Noise
				fixed SurfaceBubble;
				SimpleNoise_float(AppendUV, 20, SurfaceBubble);
				//

                fixed SurfaceBubbleClamp = saturate((SurfaceBubble * 4 - 2));
                fixed UVuOneMinus = (1.0 - i.uv0.r);
				fixed sinTimeA = (sin(_Time.a)) * 0.005 + 0.035;
				fixed UVuMove = sinTimeA * sin((((_Time.g * (_Speed * 0.7  +0.3)) + UVuOneMinus) + 0.1) * 8.0);
                fixed RootB = ((UVuMove * (1.0 - Uabs)) * OneMinusA) + (Side - Mult);
                fixed3 SurfaceColor = lerp(_WaterHightColor.rgb, _WaterMainColor.rgb, saturate((RootB * 5.0 - 1.5)));

                fixed AMask = saturate((RootA * 50 - 26));
				fixed BMask = saturate((RootB * 50 - 25.3));
				fixed WaterMask = 1.0 - (BMask * AMask);

				///////Use Voronoi BubbleV
				fixed3 SurfaceBubbleRGB = (SurfaceBubbleClamp * _WaterHightColor.rgb * (1.0 - (RootB * 6.67 - 2.33)) * Bubble) + SurfaceColor;
				fixed BubbleAppearance = saturate(1.0 - abs((BubbleV - (Cells * 0.07/*zuida*/ + 0.05/*zuixiao*/)) * 2) * 10 - 0.35/*两边挤压*/);
				fixed3 BubbleA = _WaterHightColor.rgb * BubbleAppearance * (CentreClamp * (RootA * 2)) * 0.3;
				fixed3 outline = _OutlineColor.rgb * saturate((i.uv0.g * -6.67 + 1.0)) * clamp(_Quantity, 0, 0.7);
                fixed3 APlusB = lerp((BubbleA + ((_WaterMainColor.rgb + outline) * (CentreMask * -1.0 + 1.5))), SurfaceBubbleRGB, AMask);
                
				float UVuoffs = (i.uv0.r + _CentreMaskOffsetU); // CentreMask
				fixed2 UVapp = float2(UVuoffs,(i.uv0.g + _CentreMaskOffsetV)); // CentreMask
				fixed WCentreMask = saturate(length(UVapp * 2.0 - 1.0)); // CentreMask
                fixed WaterSpherMask = 1-saturate((WCentreMask * WCentreMask * WCentreMask * WCentreMask * WCentreMask) * 2.5);

				fixed4 _MaskTexture_var = tex2D(_MaskTexture,i.uv0);
				fixed MaskTexAlpha = _MaskTexture_var.a * saturate(WaterSpherMask + _sideAlpha);
                
                fixed LineA = RootA * 20.0 - 10.5;
                fixed LineB = (1.0 - saturate((abs((RootB * 20.0 - 10.2)) * 10.0))) * saturate(LineA) * 0.2;
                fixed LineAOneMinus = 1.0 - saturate((abs(LineA) * 5.0));
                fixed LineAll = (LineB+(LineAOneMinus * 0.5)) *WaterSpherMask;


				fixed3 glassDarken = lerp(darken, (saturate(_WaterHightColor.rgb * CentreDivide * 0.45) + APlusB), (MaskTexAlpha * WaterMask));
				fixed3 glass = glassDarken + fixed3(0.2, 0, 0.5) * (1.0 - saturate((length(fixed2((UVRemap.r - 0.79), UVRemap.g)) * 2 - 0.2)));
				fixed3 highlight = lerp((glass + (_WaterHightColor.rgb * saturate((LineAll * MaskTexAlpha)))), _HighlightColor.rgb, _MaskTexture_var.r);
                fixed3 finalColor = lerp(lerp(highlight, _RimColor.rgb, _MaskTexture_var.g), (_OutlineColor.rgb * 3.0), _MaskTexture_var.b) * (1.0 - _MaskTexture_var.b);
                fixed AlphaClamp = saturate((WaterMask * MaskTexAlpha));
                fixed4 finalRGBA = fixed4(finalColor, saturate(((LineAll * MaskTexAlpha) + max(max(max(_MainTexture_var.a, AlphaClamp), _MaskTexture_var.r), _MaskTexture_var.b))));
				fixed4 final = fixed4(Bubble.xxx,1);
				return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
