Shader "HeroGo/Effect/BlackCutTo/A" {
    Properties {
        _MainValue ("MainValue", Range(0, 2)) = 0.3
        [MaterialToggle] _InvertAlpha ("Invert Alpha", Float ) = 0
        _CenterPosition ("CenterPosition", Range(-1, 1)) = 0
        _MainTex ("Main Tex", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent-3"
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
                float RotatorCos = cos(-1.7);
                float RotatorSin = sin(-1.7);
                float2 Rotator_piv = float2(0.5,0.5);
                o.Rotator = (mul(o.AppUV - Rotator_piv,float2x2( RotatorCos, -RotatorSin, RotatorSin, RotatorCos)) + Rotator_piv);

                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                fixed3 Yellow = fixed3(1,1,0);
                fixed3 Red = fixed3(1,0,0);
                
                fixed CenterMask = length(i.AppUV * 2.0 - 1.0);
                fixed2 UVx2 = lerp( i.AppUV, i.Rotator, CenterMask ) * 2.0 - 1.0;
                fixed2 AppUV02 = float2( ( ( ( atan2( UVx2.r, UVx2.g ) * 0.16 ) + 0.5 ) * 3.0) +_MainValue, CenterMask +  1.0 - _Time.r );
                fixed invert = tex2D(_NoiseTex, TRANSFORM_TEX( AppUV02, _NoiseTex )).r;
                fixed CentreMaskz = ( invert * CenterMask ) + ( CenterMask * 0.7 );
                fixed StartPoint = _MainValue * 4.0 - 0.3 ;
                fixed addBreadth = StartPoint + 0.3;
                fixed CentreMaskResult = saturate( ( CentreMaskz - StartPoint ) / 0.3 );
                fixed InvertAlphaVar = lerp( CentreMaskResult, (1.0 - CentreMaskResult), _InvertAlpha );
                fixed EdgeOr = abs(InvertAlphaVar - 0.5) * 2.0;
                fixed3 HiLightEdge = lerp( Yellow, Red, ( EdgeOr * 2.0 ) );
                fixed2 FireUVStretch = float2( ( 5.0 * i.uv0.r ), i.uv0.g );
                float2 Vmove = i.uv0 + _Time.g * float2( 0, -0.2);
                fixed NoiseAvMove = tex2D( _NoiseTex, TRANSFORM_TEX( Vmove, _NoiseTex ) ).b;
                fixed NoiseALerpResult = lerp((-0.007), 0.007, NoiseAvMove);
                fixed FireUVdisturbance = lerp( NoiseALerpResult * 0.3, NoiseALerpResult, saturate( saturate( i.uv0.g * 2.273 - 0.523 ) * 0.84 + 0.16) );
                fixed2 FireUV = float2( FireUVStretch.r + FireUVdisturbance , FireUVStretch.g );
                fixed2 FireMoveUV = FireUV + _Time.g * float2( -0.02, -0.15 );
                fixed2 FireTex = tex2D( _NoiseTex, TRANSFORM_TEX( FireMoveUV, _NoiseTex ) ).rg; // Fire
                fixed FireSpaceOr = max( FireTex.r ,FireTex.g);
                float fireSpace = (1.0 - ( abs( i.uv0.g - 0.65 ) * 2.0 ) ) * -1.26 + 1.564;
                float3 fierz = lerp( lerp( Red, Yellow, FireSpaceOr ), Red, fireSpace );
                fixed2 AppUV03 = float2( i.uv0.r + FireUVdisturbance, i.uv0.g );
                fixed2 MainTexVar = tex2D( _MainTex, TRANSFORM_TEX( AppUV03, _MainTex ) ).rg;
                fixed3 MainR = float3( MainTexVar.r,MainTexVar.r * 1.0 - 0.5, MainTexVar.r * 1.25 - 0.75 );
                fixed YanJiangShanshuo = abs( frac( _Time.g * 0.5) - 0.5 ) * 8.0; // YanJiangLirFengShanShuo
                float3 BackGround_Or = MainR + ( MainR * YanJiangShanshuo * MainTexVar.g * FireSpaceOr * FireSpaceOr );
                fixed FireSpace = saturate( fireSpace + ( ( 1.0 - FireSpaceOr ) * 0.2 ) );
                fixed3 mainBackGround = lerp( fierz, BackGround_Or, FireSpace );
                fixed3 finalColor = lerp( HiLightEdge, mainBackGround, EdgeOr );
                return fixed4( finalColor, max( InvertAlphaVar, 1.0 - EdgeOr ) );
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
