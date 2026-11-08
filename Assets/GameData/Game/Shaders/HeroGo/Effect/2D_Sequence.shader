Shader "HeroGo/Effect/2D_Sequence" 
{
    Properties 
	{
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Intensity ("Intensity", Range(0, 3)) = 1
        _Wide ("Wide", Float) = 2
        _Height ("Height", Float) = 4
        _Speed ("Speed", Float) = 1
		[Toggle(_SPEED)] _TimeSpeed("Time Speed", Int) = 0
        _Slider ("Speed Slider", Float) = 1
		[Space(10)]
		//
		[Toggle(_EMISSION)] _Emission("Emissive On/Off", Int) = 0
		_TimeOnDuration("ON Duration", Float) = 0.2
		_TimeOffDuration("OFF Duration", Float) = 0.5
		_BlinkingTimeOffsScale("Blinking Time", Float) = 5
		_NoiseAmount("Noise Amount", Range(0, 1)) = 0.15
    }

    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Pass {		    
			Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile _ _SPEED
			#pragma multi_compile _ _EMISSION
            #include "UnityCG.cginc"
            #pragma target 2.0

            float _Speed;
            float _Slider;
            float _TimeSpeed;
            float _Wide;
            float _Height;
            sampler2D _MainTex; 
            float4 _MainTex_ST;
            float _Intensity;
            fixed4 _Color;

			float _TimeOnDuration;
			float _TimeOffDuration;
			float _BlinkingTimeOffsScale;
			float _NoiseAmount;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float3 uv0 : TEXCOORD0;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0.xy = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex);

				float recip01 = (1.0 / _Wide);
                float recip02 = (1.0 / _Height);
                float count = (_Wide * _Height);
#ifdef _SPEED
				float speed = count * frac(_Time * _Speed);
#else
				float speed = _Slider;
#endif
                float horizontal = floor(fmod(speed, _Wide));

				float2 uv01 = float2(0.0, (_Height - 1.0) * recip02) + float2(v.texcoord0.r, v.texcoord0.g) / float2(_Wide, _Height);
				o.uv0.xy = (float2(recip01, recip02) * float2(horizontal, (-1 * floor((fmod(speed, (_Height * _Wide)) / _Wide))))) + uv01;

#ifdef _EMISSION
				float time = _Time.y + _BlinkingTimeOffsScale;
				float fracTime = fmod(time, _TimeOnDuration + _TimeOffDuration);
				float wave = smoothstep(0, _TimeOnDuration * 0.25, fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75, _TimeOnDuration, fracTime));
				float noiseTime = time * (6.2831853 / _TimeOnDuration);
				float noise = (sin(noiseTime) + 1) * (0.5 * cos(noiseTime * 0.6366 + 56.7272) + 0.5);
				float noiseWave = _NoiseAmount * noise + (1 - _NoiseAmount);
				wave = _NoiseAmount < 0.01 ? wave : noiseWave;
				o.uv0.z = wave;
#else
                o.uv0.z = 1;
#endif
                return o;
            }

            fixed4 frag(VertexOutput i) : COLOR 
			{
                fixed4 col = tex2D(_MainTex, TRANSFORM_TEX(i.uv0, _MainTex));

                fixed4 finalColor = _Intensity * col * _Color * i.uv0.z;

                return finalColor;
            }
            ENDCG
        }
    }
 
}
