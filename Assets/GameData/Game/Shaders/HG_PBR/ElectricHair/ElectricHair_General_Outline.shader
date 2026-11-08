Shader "HeroGo/ElectricHair/Outline"
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

		//OUTLINE
		_ScaleTimeLen("Scale time length", Range(0, 10)) = 0.23333331
		_ScaleWidth("Scale width", Range(1, 10)) = 3.5
		_BeginScale("Begin Scale", Range(0, 10)) = 3
		_Outline("Outline Width", Range(0.0, 0.01)) = 0.001
		_OutlineColorBegin("Begin Outline Color", Color) = (1.0, 0.0, 0.0, 1)
		_OutlineColorEnd("End Outline Color", Color) = (1.0, 1.0, 0.0, 1)
		[HideInInspector]_ElapsedTime("Elapsed time", Float) = 0
		[HideInInspector]_WorldRefPos("World ref position", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase"
		       "Queue" = "Transparent" 
			   "RenderType" = "Transparent"       
		}
        LOD 100
		Pass
		{
		    Cull Back
			Lighting Off
			Zwrite On
			ZTest On

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

                return col;
            }
            ENDCG
        }
		Pass
		{
			Name "OUTLINE_DOWNGRADE"

			Cull Back
			Lighting Off
			Fog{ Mode Off }
			//ZTest On
			Blend SrcAlpha One
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 factor : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 ViewDir : TEXCOORD2;
			};

			half _Outline;
			half _ZSmooth;
			uniform fixed4 _OutlineColorBegin;
			uniform fixed4 _OutlineColorEnd;

			half _ElapsedTime;
			half _BeginScale;
			half _ScaleTimeLen;
			half _ScaleWidth;
			float4 _WorldRefPos;
			
			v2f vert(a2v v)
			{
				 v2f o;
				 o.factor.xy = saturate((_ScaleTimeLen - _ElapsedTime) / _ScaleTimeLen);
				 
				 //Correct Z artefacts
				 float4 pos = mul(unity_ObjectToWorld, v.vertex);
				 o.ViewDir = normalize(_WorldSpaceCameraPos - pos);
				 
				 pos.xyz -= _WorldRefPos;
				 pos.xyz *= (1.005 + o.factor.x * _BeginScale * half3(_ScaleWidth, 1, _ScaleWidth));
				 pos.xyz += _WorldRefPos;				
				 pos = mul(UNITY_MATRIX_V, pos);
				 
				 float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				 normal.z = _ZSmooth;
				 
				 //Camera-independent size
				 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));				 				 

				 o.pos = mul(UNITY_MATRIX_P, pos);
				 o.normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0)));

				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				// Outline flash
				half3 color = lerp(_OutlineColorEnd, _OutlineColorBegin, IN.factor.x);
				half fresnel = 1.0 - saturate(dot(IN.normal, IN.ViewDir));

				return half4(pow(fresnel, 2) * color * 2, fresnel * 2);
			}
			ENDCG
		}
    }
	FallBack "HeroGo/ElectricHair/General"

}
