Shader "HeroGo/Effect/Holographic" 
{
	Properties 
	{
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _Emission ("Emission", Float) = 1.0	  
        _InterlacePattern ("Interlace Pattern", 2D) = "white" {}
		_ScanningWidth ("Scanning Width", Range(0, 10)) = 2
		_ScanlineColor ("Scanline Color", Color) = (1, 1, 1, 1)
		_Speed ("Speed", Range(0, 6)) = 1
	}
	
	SubShader 
	{
	 Cull Off
	 ZWrite Off
     Blend One One

       Tags 
	   { 
	   "IgnoreProjector"="True"
	   "Queue"="Transparent"      
       "RenderType"="Transparent"
	    }
		
	    Pass {
	
		CGPROGRAM		
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		#pragma target 2.0

		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _InterlacePattern;						
		float4 _InterlacePattern_ST;
		fixed4 _MainColor;
		float _Emission;
		fixed4 _ScanlineColor;
		float _Speed;
		float _ScanningWidth;
		
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
										
		struct v2f 
		{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;		
		};

		v2f vert(appdata v)
		{
			v2f o;
			
			o.pos = UnityObjectToClipPos (v.vertex);	
			o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
			o.uv.zw = TRANSFORM_TEX(v.uv, _InterlacePattern);			
					
			return o; 
		}
		
		fixed4 frag( v2f i ) : COLOR
		{	
			fixed4 colorTex = tex2D (_MainTex, i.uv) * _MainColor * _Emission;
			fixed4 interlace = tex2D (_InterlacePattern, i.uv.zw * _ScanningWidth  + _Time.xx * _Speed) * _ScanlineColor;
			colorTex *= interlace;
			
			return colorTex;
		}
		
		ENDCG
		 
		}
				
	} 

}
