// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ImageEffect/MaskIcon"
{
	Properties
	{
		_MainTex("Base (RGB)",2D) = "white"{}
		_Mask("Mask",2D) = "white"{}

		_CutOff("Alpha CutOff",Range(0,1))=0.1
	}
    
	SubShader
   {
			Tags  {"Queue" = "Transparent"}
			Lighting Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaTest GEqual [_CutOff]

			Pass
		{
			SetTexture[_Mask]{ combine texture }
			SetTexture[_MainTex]{ combine texture,texture - previous }
		}
	}

}