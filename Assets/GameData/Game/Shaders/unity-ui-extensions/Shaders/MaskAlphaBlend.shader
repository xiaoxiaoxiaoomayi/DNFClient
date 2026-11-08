// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ImageEffect/MaskAlphaBlend"
{
	Properties
	{
		_MainTex("Base (RGB)",2D) = "white"{}
		_Mask("Mask",2D) = "white"{}

		_Alpha("Alpha",Color)= (0.5,0.5,0.5,0.5)
	}
    
	SubShader
   {
		Tags  {"Queue" = "Transparent"}
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			SetTexture[_Mask]
			{
				constantColor[_Alpha]
				combine texture + constant
			}
			SetTexture[_MainTex]
			{ 
				combine texture,texture - previous
			}
		}
	}

}

