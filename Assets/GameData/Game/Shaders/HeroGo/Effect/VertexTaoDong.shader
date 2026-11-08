Shader "HeroGo/Effect/VertexTaoDong"
{
    Properties
    {
		[Enum(Alpha Blend,10,Addtive,1)] _DestBlend("Dest Blend Mode", Float) = 1
        _Albedo ("MainCol", 2D) = "white" {}
		_OffsetTex ("OffsetTex", 2D) = "white" {}
		_NoiseTex ("NoiseTex", 2D) = "white" {}
		_Frequency("Frequency", vector) = (0, 0, 0, 0)
		_OffScale("OffScale", Range(0, 5)) = 1
		_ZPos("ZPos", Range(0, 1)) = 0
		_MainCol("MainColor", Color) = (1, 1, 1, 1)
		_ColStr("ColStrength", Range(0, 8)) = 1
		_AlphaStr("AlphaStr", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100

        Pass
        {
		   Tags {
                "LightMode"="ForwardBase"
            }

			Cull Off
			ZWrite Off
			Blend SrcAlpha [_DestBlend]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#pragma target 3.0
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
				half3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv2 : TEXCOORD0;
            };

            sampler2D _Albedo;	
			sampler2D _OffsetTex;			
			sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
			half _ZPos;
			half _OffScale;
			half4 _Frequency;
			fixed3 _MainCol;
			half _ColStr;
			half _AlphaStr;

            v2f vert (appdata v)
            {
                v2f o;
				o.uv2.xy = v.uv2;
				half4 offsetAlpha = tex2Dlod(_OffsetTex, half4(v.uv1, 0, 0));
				half2 speed = TRANSFORM_TEX(v.uv1, _NoiseTex) + (_Time * _Frequency.rg);
                half4 noise = tex2Dlod(_NoiseTex, half4(speed, 0, 0));
                v.vertex.xyz += v.normal * (noise.r + _ZPos) * offsetAlpha.r * _OffScale ;
				o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_Albedo, i.uv2);
				half3 finalCol = col.xyz * _MainCol * _ColStr;
				half alpha = col.a - _AlphaStr;
				alpha = max(alpha,0);
                return half4(finalCol, alpha);
            }
            ENDCG
        }

    }
}
