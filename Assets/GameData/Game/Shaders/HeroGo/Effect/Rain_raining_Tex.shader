Shader "HeroGo/Effect/Rain/raining_Tex" {
    Properties {
        _DyeColor ("Dye color", Color) = (1,1,1,0.7)
        _VoronoiTex ("Voronoi Tex", 2D) = "white" {}
        _Size ("Size", Range(0.9, 0.99)) = 0.97
        _Rate ("Rate", Range(0, 1)) = 0.6
        _Density ("Density", Range(0, 2.5)) = 0.67
        _Speed ("Speed", Range(0, 2)) = 1
        _Rotator ("Rotator", Range(-0.1, 0.1)) = -0.065
        _quantity ("Quantity", Range(0, 1)) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {


            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 2.0

             float4 _DyeColor;
             sampler2D _VoronoiTex;  float4 _VoronoiTex_ST;
             float _Rate;
             float _Density;
             float _Speed;
             float _Size;
             float _Rotator;
             float _quantity;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
				float2 vorUV : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );

				float rotator_cos = cos(_Rotator);
                float rotator_sin = sin(_Rotator);
                float2 rotator_piv = float2(0.5,1);
                float2 rotator_ = mul(v.texcoord0 - rotator_piv, float2x2( rotator_cos, -rotator_sin, rotator_sin, rotator_cos)) + rotator_piv;
                float2 scaleUV = lerp(float2(0.5,0.5),float2(rotator_.r,((_Speed*_Time.g)+rotator_.g)),_Density).rg;
                float ROM = 1.0 - _Rate; // RateOneMinus
                float index = 1.0 - ROM * ROM;
                o.vorUV = float2( lerp( 0.5,scaleUV.r,index * 6.0 + 1.0 ),lerp( 0.5, scaleUV.g, index * -0.93 + 1.0) ); // VoronoUV

                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                float4 voronoiTexVar = tex2D(_VoronoiTex,TRANSFORM_TEX(i.vorUV, _VoronoiTex));
                float quR = _quantity * -1.2 + 1.0; // quantityRange
                float RaM = quR + 0.2; // RangeMax
                float aA = saturate( ( voronoiTexVar.g - quR ) * 5 );
				float timeScale = ( _quantity * 0.9 + 0.1 );
                float aB = lerp( 1, abs( frac( voronoiTexVar.g + ( _Time.a * timeScale ) ) - 0.5 ), _quantity );
                float AoMax = aA * aB;
                float Aresult = (voronoiTexVar.r - _Size) * AoMax  / (1.0 - _Size);
                float sO = saturate( _Size + 0.04 ); // sizeOffset  0.94~1.03
                float bA = saturate( ( voronoiTexVar.a - quR) * 5 );
                float bB = lerp( 1, ( abs( frac( voronoiTexVar.a + ( _Time.g * timeScale ) ) - 0.5 ) * 2.0 ), _quantity);
                float BoMax = bA * bB;
				float Bresult = ( ( voronoiTexVar.b - sO ) * BoMax ) * (_Size * -174.33 + 173.56);
                fixed mainAlpha = saturate(max(Aresult, Bresult));
                fixed under = saturate( i.uv0.g * 2.0 );
                fixed orTr = 0.6; // Overall transparency
                fixed Alpha = mainAlpha * under * _DyeColor.a;
                return fixed4(_DyeColor.rgb,Alpha);
            }
            ENDCG
        }
    }
}