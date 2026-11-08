// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/UI/Brighten"
{
	Properties
	{
		[PerRendererData] _MainTex("Base (RGB)", 2D) = "white" {}
		_Brighteness("Brighteness", Range(0,1)) = 0.2
	}

	//通过CGINCLUDE我们可以预定义一些下面在Pass中用到的struct以及函数，  
	//这样在pass中只需要设置渲染状态以及调用函数,shader更加简洁明了  
	CGINCLUDE
	#include "UnityCG.cginc"  

	//blur结构体，从blur的vert函数传递到frag函数的参数  
	struct v2f_blur
	{
		float4 pos : SV_POSITION;   //顶点位置  
		float2 uv  : TEXCOORD0;     //纹理坐标  
	};

	//shader中用到的参数  
	sampler2D _MainTex;
	//XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height  
	float _Brighteness;

	//vertex shader  
	v2f_blur vert(appdata_img v)
	{
		v2f_blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		//uv坐标  
		o.uv = v.texcoord.xy;
		return o;
	}

	//fragment shader  
	fixed4 frag(v2f_blur i) : SV_Target
	{
		fixed4 color;
		color.rgb = lerp(tex2D(_MainTex, i.uv).rgb ,1, _Brighteness);
		color.a = 1;
		return color;
	}
	ENDCG

	//开始SubShader  
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		//开始一个Pass  
		Pass
		{
			//后处理效果一般都是这几个状态  
			ZTest Always
			Cull Off
			ZWrite Off
			Blend One Zero

			Fog{ Mode Off }

			//使用上面定义的vertex和fragment shader  
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag  
			ENDCG
		}
	}
	//后处理效果一般不给fallback，如果不支持，不显示后处理即可  
}
