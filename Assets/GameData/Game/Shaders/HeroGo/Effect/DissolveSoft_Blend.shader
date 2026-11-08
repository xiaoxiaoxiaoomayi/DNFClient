Shader "HeroGo/Effect/DissolveSoft_Blend" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
		_Noise ("Noise Texture", 2D) = "white" {}
        _Mask ("Mask Texture", 2D) = "white" {}
		_Dissolve ("Dissolve", Range(0, 1)) = 0
        _EdgeColor ("Edge_Color", Color) = (1,1,1,1)
        _EdgeWidth ("Edge Width", Range(0, -0.05)) = 0
		_SoftEdge ("Soft Edge", Range(0.5, 1)) = 0.5

    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 2.0
           
			fixed4 _MainColor;
            sampler2D _MainTex;
			float4 _MainTex_ST;
            sampler2D _Mask; 
			float4 _Mask_ST;
            fixed _SoftEdge;
            sampler2D _Noise;
			float4 _Noise_ST;
            fixed _Dissolve;
            fixed4 _EdgeColor;
            fixed _EdgeWidth;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {

                fixed4 MainColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));

                fixed4 NoiseColor = tex2D(_Noise,TRANSFORM_TEX(i.uv0, _Noise));
                fixed  Dissolve = ((2.0 * (1.0 - i.vertexColor.a)) + _Dissolve);
                float3 FinalColor = lerp((MainColor.rgb * _EdgeColor.rgb),(MainColor.rgb * _MainColor.rgb * i.vertexColor.rgb),smoothstep( (1.0 - _SoftEdge), _SoftEdge, saturate(((NoiseColor.r+1.0) + (-2 * Dissolve))) ));
                fixed4 MaskColor = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                return fixed4(FinalColor,(MainColor.a * _MainColor.a * MaskColor.r * smoothstep( (1.0 - _SoftEdge), _SoftEdge, saturate(((NoiseColor.r+1.0)+(saturate((_EdgeWidth + Dissolve))* -2))) )));
            }
            ENDCG
        }
    }
}
