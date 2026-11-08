Shader "HeroGo/Particle/AlphaBlend_Scroll" {
    Properties {
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Particle Texture", 2D) = "white" {}
        _Scroll ("Scroll", Range(-0.5, 1)) = 0
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
            Cull Off
			Lighting Off
			ZWrite Off 
			Fog { Color (0,0,0,0) }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 2.0
             sampler2D _MainTex; 
			 float4 _MainTex_ST;
             fixed4 _TintColor;
             fixed _Scroll;

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
                clip((i.uv0.g + _Scroll) - 0.5);

                fixed4 col = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed3 finalColor = (col.rgb * i.vertexColor.rgb * _TintColor.rgb * 2.0);
                fixed4 finalRGBA = fixed4(finalColor,(col.a * i.vertexColor.a * _TintColor.a));  
                return finalRGBA;
            }
            ENDCG
        }
    }
}
