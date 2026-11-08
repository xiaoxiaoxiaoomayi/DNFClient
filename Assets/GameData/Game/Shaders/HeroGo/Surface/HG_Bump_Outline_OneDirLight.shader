Shader "HeroGo/General/OneDirLight/Bumped_Outline"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)

		_ScaleTimeLen("Scale time length", Range(0, 10)) = 0.23333331
		_ScaleWidth("Scale width", Range(1, 10)) = 3.5
		_BeginScale("Begin Scale", Range(0, 10)) = 3
		//OUTLINE
		_Outline("Outline Width", Range(0.0, 0.01)) = 0.001
		_OutlineColorBegin("Begin Outline Color", Color) = (1.0, 0.0, 0.0, 1)
		_OutlineColorEnd("End Outline Color", Color) = (1.0, 1.0, 0.0, 1)
		[HideInInspector]_ElapsedTime("Elapsed time", Float) = 0
		[HideInInspector]_WorldRefPos("World ref position",Vector) = (0,0,0,0)
	}

	SubShader
	{

		ZWrite On
		ZTest On
		Stencil
		{
			Ref 1
			Comp Always
			Pass Replace
			ZFail Keep
		}

		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#include "../Inc/Toon.cginc"

		/// nolightmap nodirlightmap		LIGHTMAP
		/// noforwardadd					ONLY 1 DIR LIGHT (OTHER LIGHTS AS VERTEX-LIT)
		#pragma surface surf Cartoon nolightmap nodirlightmap noforwardadd finalcolor:final
		/// Use shader model 3.0 target, to get nicer looking lighting
		/// #pragma target 3.0

		sampler2D _MainTex; /// Albedo
		sampler2D _BumpMap; /// Bump

		struct Input
		{
			float2 uv_MainTex : TEXCOORD0;
			float2 uv_BumpMap : TEXCOORD1;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			/// Albedo comes from a texture tinted by color
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			/// Normal map
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}

		void final(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			color.rgb = color.rgb * color.a;
		}

		ENDCG
		UsePass "Hidden/HeroGo/OutLine_Downgrade/OUTLINE_DOWNGRADE"
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}
