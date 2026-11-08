Shader "HeroGo/Effect/Rain/splash" {
    Properties {
        _DyeColor ("Dye color", Color) = (1,1,1,1)
        _Rate ("Rate", Range(1, 2)) = 2
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
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #pragma target 2.0

            fixed4 _DyeColor;

            float Function( float In ){
            fixed Out = 2 * abs( In - 0.5 );
            return Out;
            }
            
            uniform fixed _Rate;
            struct VertexInput {
                float4 vertex : POSITION;
                float4 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                fixed Center = 1.0 - length( float2( i.uv0.r, lerp( 0.5, i.uv0.g, _Rate ) ) * 2.0 - 1.0 );
                fixed cenSh = Center + i.uv0.b * 1.5; // centerShape
                fixed wave = Function( frac( ( 3.0 * i.uv0.b ) + Center) );
                fixed MEA = saturate( saturate( min( cenSh * -5 + 7.5 , cenSh * 10 - 5) ) * wave * saturate( Center ) ); // MainEffectAlpha
                float3 finalColor = (_DyeColor.rgb*i.vertexColor.rgb)*MEA*_DyeColor.a*i.vertexColor.a;
                return fixed4(finalColor,1);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
