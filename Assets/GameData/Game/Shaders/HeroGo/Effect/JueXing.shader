Shader "HeroGo/Effect/JueXing" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
		_NoiseTex ("Noise Tex", 2D) = "white" {}
        _NoiseSpeed ("Noise Speed", Range(0, 1)) = 0.5
        _NoiseWeight ("Noise Weight", Range(0, 1)) = 0.5
        _NoiseDensity ("Noise Density", Range(0, 1)) = 0.5
        _NoiseUVTilingOffset ("Noise UV Tiling Offset", Vector) = (1,1,0,0)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 2.0
            
             sampler2D _MainTex;  float4 _MainTex_ST;
			 sampler2D _NoiseTex;
             fixed4 _NoiseUVTilingOffset;
             float _NoiseSpeed;
             fixed _NoiseWeight;
             fixed _NoiseDensity;

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
				float2 NoiseUV = float2((_NoiseUVTilingOffset.b+(_NoiseUVTilingOffset.r*i.uv0.r)),(_NoiseUVTilingOffset.a+(_NoiseUVTilingOffset.g*((_NoiseSpeed*_Time.g)-i.uv0.g))));
				NoiseUV = lerp(float2(0.5,0.5), NoiseUV, _NoiseDensity  *  0.83 + 0.166 );
				fixed Noise = tex2D(_NoiseTex,NoiseUV).r;

                float2 TexUV = float2((i.uv0.r+((Noise-0.5)*(_NoiseWeight*0.05))),i.uv0.g);
                fixed4 MainTexVar = tex2D(_MainTex,TRANSFORM_TEX(TexUV, _MainTex));
                fixed3 finalColor = MainTexVar.rgb;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
