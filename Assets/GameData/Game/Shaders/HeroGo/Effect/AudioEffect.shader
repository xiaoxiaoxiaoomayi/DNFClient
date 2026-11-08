Shader "HeroGo/Effect/AudioEffect"
{
	Properties
	{
		[Enum(Alpha Blend, 10, Addtive, 1)] _DestBlend("Dest Blend Mode", float) = 1
		_AudioPass ("音频影响范围", 2D) = "white" {}
		_AudioWave ("音频波形", 2D) = "white" {}
		_MoveSpeed("波速率", Vector) = (0, -8, 0, 4)
		[Toggle(_AudioStyle)] _AudioStyle("音频风格切换", int) = 0
		_EmissionInt("颜色亮度", Range(0.5, 4)) = 1
		_TintColor("主颜色", color) = (1, 1, 1, 1)
		_TopCol("顶部颜色", color) = (1, 1, 1, 1)
		[Toggle(_Gradient)] _Gradient("是否使用渐变过渡", int) = 0
		_GradientInt("渐变过渡", float) = 1
		[Toggle(_EMISSION)] _Emission("Emissive On/Off", Int) = 0
		_TimeOnDuration("ON Duration", Float) = 0.2
		_TimeOffDuration("OFF Duration", Float) = 0.5
		_BlinkingTimeOffsScale("Blinking Time", Float) = 5
		_NoiseAmount("Noise Amount", Range(0, 1)) = 0.15
	}
	SubShader
	{
		Tags { 
		       "RenderType"="Transparent"
        	   "Queue"="Transparent"
			   "IgonreProjector"="True"
		}
		LOD 100
		Pass
		{
			Zwrite on
			Blend SrcAlpha [_DestBlend]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			#pragma multi_compile _ _AudioStyle
			#pragma multi_compile _ _Gradient
			#pragma multi_compile _ _EMISSION
			#pragma target 2.0

			struct appdata
			{
				float4 vertex    : POSITION;
				float2 uv        : TEXCOORD0;
				half4 vecColor  : COLOR;
			};
			struct v2f
			{				
				float4 position   : SV_POSITION;
				float3 uv         : TEXCOORD0;
				half vecAlpha	  : TEXCOORD1;
			};

			sampler2D _AudioPass;
			half4 _AudioPass_ST;
			sampler2D _AudioWave;
			half4 _MoveSpeed;
			half3 _TintColor;
			half3 _TopCol;
			half _GradientInt;

			half _TimeOnDuration;
			half _TimeOffDuration;
			half _BlinkingTimeOffsScale;
			half _NoiseAmount;
			half _EmissionInt;

	v2f vert (appdata v)
	{
		v2f o;
		UNITY_INITIALIZE_OUTPUT(v2f, o);
		o.uv.xy  = TRANSFORM_TEX(v.uv, _AudioPass);
		o.position = UnityObjectToClipPos(v.vertex);
		o.vecAlpha = v.vecColor.a;

		#ifdef _EMISSION
				half time = _Time.y + _BlinkingTimeOffsScale;
				half fracTime = fmod(time, _TimeOnDuration + _TimeOffDuration);
				half wave = smoothstep(0, _TimeOnDuration * 0.25, fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75, _TimeOnDuration, fracTime));
				half noiseTime = time * (6.2831853 / _TimeOnDuration);
				half noise = (sin(noiseTime) + 1) * (0.5 * cos(noiseTime * 0.6366 + 56.7272) + 0.5);
				half noiseWave = _NoiseAmount * noise + (1 - _NoiseAmount);
				wave = _NoiseAmount < 0.01 ? wave : noiseWave;
				o.uv.z = wave;
		#else
                o.uv.z = 1;
		#endif
		return o;
		}
			
	half4 frag (v2f i) : SV_Target
	{
	
		
		float2 waveUV1 = float2(trunc( _Time.x * _MoveSpeed.x)/_MoveSpeed.y, 1) + i.uv.xy;
		float2 waveUV2 = float2(trunc( _Time.x * _MoveSpeed.z)/_MoveSpeed.w, 1) + i.uv.xy;
		fixed3 waveMove1 = tex2D(_AudioWave, waveUV1);
		fixed4 waveMove2 = tex2D(_AudioWave, waveUV2);
		fixed4 wavePass = tex2D(_AudioPass,i.uv.xy);

		#ifdef _AudioStyle
			half Alpha = waveMove1.x * wavePass.x + waveMove2.y * wavePass.y;
			#ifdef _Gradient
			Alpha = wavePass.z * _GradientInt * Alpha * i.vecAlpha;
			Alpha = min(Alpha, 1);
			#endif
			half topColPass = waveMove1.z * wavePass.x + waveMove2.w * wavePass.y;
			half3 finalCol = lerp(_TintColor, _TopCol, topColPass);

		#else 
		    half waveAlpha = min((wavePass.x + wavePass.y + wavePass.z), 1);
			half Alpha = waveMove1.x * (waveAlpha - wavePass.w) + waveMove2.y * wavePass.w;
			half3 finalCol = wavePass.xyz; 
		#endif

		finalCol = finalCol * i.uv.z * _EmissionInt;
		return half4(finalCol, Alpha);
			}
	ENDCG
		}
	}
	FallBack "Diffuse"

}
