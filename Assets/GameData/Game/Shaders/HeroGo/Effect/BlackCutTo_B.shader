Shader "HeroGo/Effect/BlackCutTo/B" {
    Properties {
        _MainValue ("MainValue", Range(0, 2)) = 0.3
        [MaterialToggle] _InvertAlpha ("Invert Alpha", Float ) = 0
        _CenterPosition ("CenterPosition", Range(-1, 1)) = 0
        _MainTex ("Main Tex", 2D) = "white" {}
        _MaskTex ("Mask Tex", 2D) = "white" {}
        _FollowMap ("Follow Map", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent-2"
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
            #pragma target 2.0

             sampler2D _MainTex;  float4 _MainTex_ST;
             fixed _InvertAlpha;
             fixed _MainValue;
             sampler2D _NoiseTex;  float4 _NoiseTex_ST;
             sampler2D _MaskTex;  float4 _MaskTex_ST;
             sampler2D _FollowMap;  float4 _FollowMap_ST;
             fixed _CenterPosition;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
				fixed2 AppUV : TEXCOORD1;
				fixed2 Rotator : TEXCOORD2;

            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );

				o.AppUV = float2(lerp((0.5+_CenterPosition),v.texcoord0.r,1.65),v.texcoord0.g);
                float Rotator_cos = cos(-1.7);
                float Rotator_sin = sin(-1.7);
                float2 Rotator_piv = float2(0.5,0.5);
                o.Rotator = (mul(o.AppUV - Rotator_piv,float2x2( Rotator_cos, -Rotator_sin, Rotator_sin, Rotator_cos)) + Rotator_piv);


                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                fixed CenterMask = length( i.AppUV * 2.0 - 1.0 );
                fixed2 UVx2 = lerp( i.AppUV, i.Rotator, CenterMask ) * 2.0 -1.0;
                fixed2 AppUV02 = float2( ( ( atan2( UVx2.r, UVx2.g ) * 0.16 ) + 0.5 ) * 3.0 + _MainValue, CenterMask + ( 1.0 - _Time.r ) );
                fixed invert = tex2D( _NoiseTex, TRANSFORM_TEX( AppUV02, _NoiseTex ) ).r;
                fixed CentreMaskz = invert * CenterMask + CenterMask * 0.7;
                fixed StartPoint = _MainValue * 4.0 - 0.3;
                fixed addBreadth = StartPoint + 0.3;
                fixed CentreMaskResult = saturate(( (CentreMaskz - StartPoint)  ) / 0.3);
                fixed InvertAlphaVar = lerp( CentreMaskResult, (1.0 - CentreMaskResult), _InvertAlpha );
                fixed EdgeOr = abs( InvertAlphaVar - 0.5 ) * 2.0;
                fixed3 HiLightEdge = lerp( fixed3( 1, 1, 0 ), fixed3( 1, 0, 0 ), EdgeOr * 2.0);
                float2 Vmove = i.uv0 + _Time.g * float2( 0, -0.2 );
                fixed NoiseAVmove = tex2D( _NoiseTex, TRANSFORM_TEX( Vmove, _NoiseTex ) ).b;
                fixed NoiseALerpresult = lerp( -0.007, 0.007, NoiseAVmove);
                fixed MaskRB = tex2D( _MaskTex, TRANSFORM_TEX( i.uv0, _MaskTex ) ).r;
                fixed2 AppUV03 = float2( i.uv0.r + lerp( NoiseALerpresult * 0.3 , NoiseALerpresult, 1.0 - MaskRB ), i.uv0.g);
                fixed4 FollowMapVar = tex2D(_FollowMap, TRANSFORM_TEX( AppUV03, _FollowMap ) );
                float2 followMove = float2( FollowMapVar.r, ( 3.0 * FollowMapVar.g ) ) + _Time.g * float2( -0.5, -2 );
                fixed noiseR = tex2D(_NoiseTex, TRANSFORM_TEX( followMove, _NoiseTex ) ).r;
                fixed3 Wind = noiseR * ( FollowMapVar.b * FollowMapVar.a ) * fixed3( 0.5, 0, 0 );
                fixed4 MainTexVar = tex2D( _MainTex, TRANSFORM_TEX( AppUV03, _MainTex ) );
                fixed3 finalColor = lerp( HiLightEdge, (Wind + float3( MainTexVar.r, ( MainTexVar.r * 1.0 - 0.5 ), ( MainTexVar.r * 1.25 - 0.75 ) ) ), EdgeOr );
                return fixed4( finalColor, min( MainTexVar.a * saturate( i.uv0.g * 3.546 - 1.706 ), max( InvertAlphaVar, ( 1.0 - EdgeOr ) ) ) );
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
