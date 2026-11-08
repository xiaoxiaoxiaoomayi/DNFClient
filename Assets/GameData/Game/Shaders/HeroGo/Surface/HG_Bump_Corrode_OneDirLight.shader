Shader "HeroGo/General/OneDirLight/Bumped_Corrode"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)

		[HideInInspector]_ElapsedTime("Elapsed time", Range(0, 1)) = 0.0
		_AnimTimeLen("Corrode time length", Range(0, 10)) = 1
		_CorrodeColor("Corrode Color(Toon color lit)",Color) = (0.9,0.9,0.0,1)
	}

	SubShader
	{
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

		half _ElapsedTime;
		half _AnimTimeLen;
		fixed4 _CorrodeColor;

		struct Input
		{
			float2 uv_MainTex : TEXCOORD0;
			float2 uv_BumpMap : TEXCOORD1;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			/// Albedo comes from a texture tinted by color
			fixed4 Albedo = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = Albedo.rgb;
			o.Alpha = Albedo.a;
			clip(o.Alpha - saturate(_ElapsedTime / _AnimTimeLen));
			/// Normal map
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}

		void final(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			color.rgb = color.rgb * color.a;
			fixed t = step(0.05f,o.Alpha - saturate(_ElapsedTime / _AnimTimeLen)) * 0.7 + 0.3f;
			color.rgb = color.rgb * t + (1 - t) * _CorrodeColor;
		}

		ENDCG
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}
