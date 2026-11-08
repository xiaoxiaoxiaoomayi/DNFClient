// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TropicalStorm/UVAni_Add_02"
{
	Properties {
		_1stColor("No.1颜色", Color) = (0.5, 0.5, 0.5, 0.5)
		_1stBright ("1st Bright ", Range(0.0,1.0)) = 1
		_2ndColor("No.2颜色",Color) = (0.5,0.5,0.5,0.5)
		_AddBright ("整体亮度", Range(0.0,60.0)) = 1
		
		_MainTex("No.1贴图", 2D) = "white" {}
		_2ndTex("No.2贴图",2D) = "white" {}
		
		_ScrollX ("No.1贴图 X 速度", Float) = 1.0
		_ScrollY ("No.1贴图 Y 速度", Float) = 0.0
		_Scroll2X ("No.2贴图 X 速度", Float) = 1.0
		_Scroll2Y ("No.2贴图 Y 速度", Float) = 0.0
		
	}

	SubShader {
		Tags { "Queue"="Transparent+200" "IgnoreProjector"="True" "RenderType"="Transparent" }
	//	Tags { "Queue"="Geometry+10" "RenderType"="Opaque" }
	//	Blend One One
		Blend SrcAlpha One

		Cull Off 
		Lighting Off 
		ZWrite Off
	
		
		Pass {
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _2ndTex;	
			half4 _MainTex_ST;
			half4 _2ndTex_ST;
			
			half _ScrollX;
			half _ScrollY;
			half _Scroll2X;
			half _Scroll2Y;
	
			half4 _1stColor;
			half _1stBright;
			half4 _2ndColor;
			half _AddBright;
			
			struct v2f {
				half4 pos : POSITION;
				half2 uv : TEXCOORD0;
				half2 uv2 : TEXCOORD1;
				half4 color:COLOR;
			};

			v2f vert (appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex) + (half2(_ScrollX,_ScrollY) * _Time);
				o.uv2 = TRANSFORM_TEX(v.texcoord.xy,_2ndTex) + (half2(_Scroll2X,_Scroll2Y) * _Time);
				o.color = v.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 o;
				fixed4 tex = tex2D(_MainTex,i.uv) * _1stColor ;
				fixed4 tex2 = tex2D(_2ndTex,i.uv2)* _2ndColor;
				o =(tex- _1stBright) * tex2 *  _AddBright;
				o.a = (tex.a * tex2.a) * 2 * i.color.a;
				o *= i.color;
				return o;
			}

			ENDCG 
		}
	}

	Fallback off

}
