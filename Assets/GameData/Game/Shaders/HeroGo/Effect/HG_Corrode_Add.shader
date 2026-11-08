Shader "HeroGo/Effect/Corrode_Add"
{
	Properties
	{
		_MainColor("Main Color",Color) = (1,1,1,1)
		_Intensity("Intensity",Range(1, 5)) = 1
		_MainTex("Albedo", 2D) = "white" {}
		_Noise("Noise", 2D) = "gray" {}
		_RampColor("Main Color",Color) = (1,1,1,1)
		_Ramp("Ramp", 2D) = "white" {}
		_Factor("Factor", Range(0,1)) = 0
	}
	SubShader
	{
		Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"  }
		//Tags { "Queue"="Transparent" }
		LOD 100

		//Blend SrcAlpha One
		Blend SrcAlpha One
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _Ramp;
			float4 _MainTex_ST;
			float4 _MainColor;
			float _Intensity;
			float _Factor;
			float4 _RampColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 noise = tex2D(_Noise, i.uv);
				half3 nornoise = noise.rgb;
				fixed degree = saturate(noise.x - _Factor + 0.001f);
				fixed4 ramp = tex2D(_Ramp,1-degree.x) * _RampColor;
				half3 normRamp = normalize(ramp);

				clip(degree   - 0.001f);

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _MainColor * _Intensity;
				half weight = step(_Factor*5, degree);
				col.rgb = (weight * col + (1 - weight) * ramp.rgb) ;

				return col;
			}
			ENDCG
		}
	}
}
