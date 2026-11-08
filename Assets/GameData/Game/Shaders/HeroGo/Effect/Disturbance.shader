Shader "HeroGo/Effect/Disturbance" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
		_intensity ("Intensity", Range(0, 1)) = 0.2
        _frequency ("Frequency", Range(0, 100)) = 50
		_thermalSpeed ("Speed", Range(0, 20)) = 5
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
            #pragma target 2.0

             sampler2D _MainTex;  float4 _MainTex_ST;
			 float _frequency;
			 float _thermalSpeed;
			 float _intensity;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
			float2 disturbanceUV(float4 posWorld, float2 uv0){
					float times = posWorld.y * _frequency - _Time.g * _thermalSpeed;
					float sinWave = sin(times);
					float uWave = uv0.r + sinWave * _intensity * 0.05;
					return float2(uWave, uv0.g);
					}
            float4 frag(VertexOutput i) : COLOR {
				float2 uv = disturbanceUV(i.posWorld, i.uv0);
                fixed4 MainTexVar = tex2D(_MainTex, TRANSFORM_TEX(uv, _MainTex));
                return MainTexVar;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
