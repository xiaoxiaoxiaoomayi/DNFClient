Shader "HeroGo/Effect/Smoke" {
    Properties {
        _DyeColor ("Color", Color) = (1,1,1,1)

        [PerRendererData]_MainTex ("Main Tex", 2D) = "white" {}
        _CloudsTex ("Clouds Tex", 2D) = "white" {}
        _Fade ("Fade", Range(0, 1)) = 1.0
        _TilingOffset ("Tiling Offset", Vector) = (0,0,0.02,0.02)
        _CloudsMovementController ("Clouds Movement Controller", Vector) = (0,0,0,0)
        _CoudsFormController ("Couds Form Controller", Vector) = (0,1,0,1)
        [Toggle(_InvertCloudsFlowMap)] _InvertCloudsFlowMap ("Invert Clouds FlowMap", Float ) = 0
    }
    SubShader {
        Tags {
            "Queue" = "Transparent" 
            "IgnoreProjector" = "True" 
            "RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
        }
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha

            Cull Off
		    Lighting Off
		    ZWrite Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 2.0

            #pragma multi_compile _ _InvertCloudsFlowMap

            fixed4 _DyeColor;
            fixed _Fade;
            //sampler2D _MainTex;
            sampler2D _CloudsTex;
            float4 _CloudsMovementController;
            float4 _TilingOffset;
            fixed _MaskScale;
            fixed _MaskWeight;
            float4 _CoudsFormController;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 backFlow : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                float3 posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                float backGroundVector_cos = 0.9397;//cos(0.349);
                float backGroundVector_sin = 0.342;//sin(0.349);
                float2 backGroundVector = (mul(float2((0.424 + posWorld.g), posWorld.b)- 0.5, float2x2( backGroundVector_cos, -backGroundVector_sin, 
                                                                                                     backGroundVector_sin, backGroundVector_cos))+ 0.5);
                float3 backGroundPos = float3(posWorld.r, backGroundVector.r, backGroundVector.g);
                float2 flowMove = (backGroundPos.rg + _TilingOffset.rg) * _TilingOffset.ba + _CloudsMovementController.rg * _Time.g;
                o.backFlow = float4(backGroundVector, flowMove);

                o.uv0 = v.texcoord0;
                return o;
            }
            fixed4 frag(VertexOutput i) : SV_Target {
                
                float disturbanceTex = tex2D(_CloudsTex, i.backFlow.zw).r;
            #ifdef _InvertCloudsFlowMap
                disturbanceTex = 1 - disturbanceTex;
            #endif  
                half2 flowVariable = i.backFlow.zw - (float2(-3, 1) * (_CloudsMovementController.a * disturbanceTex));
                half flowTimeSpeed = _CloudsMovementController.b * _Time.g;
                fixed flowATime = frac(flowTimeSpeed + 0.5);
                half2 flowBuv = lerp(i.backFlow.zw, flowVariable, flowATime);
                fixed4 flowB = tex2D(_CloudsTex, flowBuv);
                half flowBTime = frac(flowTimeSpeed);
                half2 flowAuv = lerp(i.backFlow.zw, flowVariable, flowBTime);
                fixed4 flowA = tex2D(_CloudsTex, flowAuv);
                half flowFlip = abs(flowATime - 0.5) * 2.0;
                fixed3 flowMap = lerp(flowB.rgb, flowA.rgb, flowFlip);
                fixed lastParameter = (_CoudsFormController.g - _CoudsFormController.r);
                lastParameter = clamp(lastParameter, 0.001, 1);
                fixed cloud = saturate(_CoudsFormController.b + ( (flowMap.r - _CoudsFormController.r) * (_CoudsFormController.a - _CoudsFormController.b) ) / lastParameter);
                
                cloud *= _DyeColor.a;
                cloud *= _Fade;
                return fixed4(_DyeColor.rgb, cloud);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
