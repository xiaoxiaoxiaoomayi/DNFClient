Shader "HeroGo/ElectricHair/Tint_Flash"
{
    Properties
    {
        _Albedo ("Main Texture", 2D) = "white" {}
		_MainColor ("Main Color", Color) = (1, 1, 1, 1)
		_Intensity ("Main Intensity", Range(1, 2)) = 1
		_ScrollX ("ScrollX", Range(-10, 10)) = 1
		_ScrollY ("ScrollY", Range(-10, 10)) = 1

		[Toggle(_DetailLayer)] _DetailLayer("Detail Layer", Int) = 0
		_DetailTex ("Detail Texture", 2D) = "white" {}		
		_DetailColor ("Detail Color", Color) = (1, 1, 1, 1)
		_DetailInt ("Detail Intensity", Range(1, 20)) = 5	
		_Scroll2X ("Scroll2X", Range(-10, 10)) = 1
		_Scroll2Y ("Scroll2Y", Range(-10, 10)) = 1		
		_Distort ("Distort", Range(-10, 10)) = 0

		_TintColor("Tint Color",Color) = (0.8, 0.0, 0.0, 1.0)
		_TintFactorUpper("Tint Degree Upper", Range(0, 1)) = 0.5
		_TintFactorLower("Tint Degree Lower", Range(0, 1)) = 0.5
		_TintFreq("Tint Freq", Range(0, 20)) = 2
		[HideInInspector]_ElapsedTime("Elapsed time", Float) = 0.0
    }
    SubShader
    {
        Tags {"LightMode" = "ForwardBase" 
		       "RenderType"="Opaque"       
		}
        LOD 100
		Pass
		{
		    Cull Back
			Lighting Off
			ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#pragma multi_compile _ _DetailLayer
			#pragma target 2.0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float TintFactor : TEXCOORD1;
            };

            sampler2D _Albedo;
            float4 _Albedo_ST;
			fixed4 _MainColor;
			float _Intensity;
			float _ScrollX;
			float _ScrollY;

#ifdef _DetailLayer
			sampler2D _DetailTex;
            float4 _DetailTex_ST;
			fixed4 _DetailColor;
			float _DetailInt;			
			float _Scroll2X;
			float _Scroll2Y;			
			float _Distort;
#endif
            //
			float _TintFactorUpper;
			float _TintFactorLower;
			float _TintFreq;
			float4 _TintColor;
			float _ElapsedTime;

            v2f vert (appdata v)
            {
                v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.vertex = UnityObjectToClipPos(v.vertex);

                float2 uv1 = TRANSFORM_TEX(v.uv, _Albedo);
				float2 speed1 = _Time.x * float2(_ScrollX, _ScrollY);
				speed1 = frac(speed1);
				o.uv.xy = uv1 + speed1;
#ifdef _DetailLayer
				float2 uv2 = TRANSFORM_TEX(v.uv, _DetailTex);
				float2 speed2 = _Time.x * float2(_Scroll2X, _Scroll2Y);
				speed2 = frac(speed2);				
				o.uv.zw = uv2 + speed2;
#endif          
                //动画材质
		        o.TintFactor = saturate((_TintFactorUpper - _TintFactorLower) * (0.5 * sin(_ElapsedTime * _TintFreq * 3.1415926) + 0.5) + _TintFactorLower);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 mainCol = tex2D(_Albedo, i.uv.xy) * _MainColor.rgb * _Intensity;
#ifdef _DetailLayer
				float2 distortUV = _Distort * mainCol.r + i.uv.zw;				
				fixed3 detailCol = tex2D(_DetailTex, distortUV) * _DetailColor.rgb * _DetailInt;
				fixed3 finalCol = mainCol + detailCol;
#else
                fixed3 finalCol = mainCol;
#endif               
				fixed4 col = fixed4(finalCol, 1);

				//动画材质
		        col.rgb = lerp(col.rgb, _TintColor.rgb, saturate(i.TintFactor));

                return col;
            }
            ENDCG
        }
    }
	FallBack "HeroGo/ElectricHair/General"

}
