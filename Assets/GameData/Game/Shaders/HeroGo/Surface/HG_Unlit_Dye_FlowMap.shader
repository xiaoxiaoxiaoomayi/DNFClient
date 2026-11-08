Shader "HeroGo/General/UnLit/HG_Unlit_Dye_FlowMap" {
    Properties {
		_DyeColor("Dye color",Color) = (1.0,1.0,1.0,1.0)
		_ColorStrength("Color Strength",Range(0, 1)) = 0.3
	    _MainTex ("Sprite Texture", 2D) = "white" {}
        _DirstTex ("Distort Texture", 2D) = "white" {}
        _Speed ("Speed", Float ) = 20 
		[HideInInspector]_AlphaFactor("Alpha factor",Range(0,1)) = 1.0


    }
    SubShader {
        Tags {
             "Queue"="Transparent"
             "IgnoreProjector"="True"
             "RenderType"="Transparent"
        }
        Pass {
             ZWrite Off
             Blend SrcAlpha OneMinusSrcAlpha
           
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "../../Includes/TMShaderSupport.cginc"
            #pragma target 2.0

			fixed4 _DyeColor;
             float _Speed;
             sampler2D _DirstTex; 
			 fixed4 _DirstTex_ST;
             sampler2D _MainTex; 
			 fixed4 _MainTex_ST;
			half _ColorStrength;
			fixed _AlphaFactor;

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
                o.pos = UnityObjectToClipPos(v.vertex );

                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                float2 flowUvOffset = floor(i.uv0);
                float2 Duv = float2(i.uv0.x, sin((i.uv0.x + _Time.g * 0.05/*速度*/)  * 80/*频率*/) * 0.005/*幅度*/ +i.uv0.y);
                Duv = lerp(Duv, i.uv0, _Speed * 0.05);
                fixed4 flowMap = tex2D(_DirstTex, TRANSFORM_TEX(Duv, _DirstTex));
                fixed2 flowUV = flowMap.rg + flowUvOffset;
                flowUV = lerp(i.uv0, flowUV, flowMap.b);
                float Speed = frac(_Time.r * _Speed);
                float2 Lerp01 = lerp(i.uv0, flowUV, Speed);
                fixed4 MainCol01 = tex2D(_MainTex,TRANSFORM_TEX(Lerp01, _MainTex));
                float2 Lerp02 = lerp(i.uv0, flowUV, frac(Speed + 0.5));
                fixed4 MainCol02 = tex2D(_MainTex,TRANSFORM_TEX(Lerp02, _MainTex));
                float LitSpeed = abs(Speed * 2.0 - 1.0);
                fixed4 col;
                col.rgb = lerp(MainCol01.rgb, MainCol02.rgb, LitSpeed) * _DyeColor;
				col.rgb = lerp(col.rgb, col.rgb * SafeNormalize(col.rgb), _ColorStrength);
                col.a = lerp(MainCol01.a, MainCol02.a, LitSpeed);
				col.a *= _AlphaFactor;
                //return fixed4(Lerp01,0,1);
                return col;
            }
            ENDCG
        }
		
    }
}
