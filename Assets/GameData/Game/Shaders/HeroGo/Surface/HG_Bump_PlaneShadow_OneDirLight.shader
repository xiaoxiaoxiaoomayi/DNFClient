Shader "HeroGo/General/OneDirLight/Bumped_PlaneShadow"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump (RGB)", 2D) = "white" {}
		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}

		_ShadowColor("Shadow Color(Toon color in shadow)",Color) = (0.0,0.0,0.0,0.0)
		_LittenColor("Litten Color(Toon color lit)",Color) = (1.0,1.0,1.0,1.0)


		_LightDir("Light Dir", Vector) = (0,1,0,0)
		_ShadowPlane("Shadow Plane", Vector) = (0,1,0,0)
		_ShadowPlaneColor("Shadow Color(RGB color A density)",Color) = (0.2,0.1,0.3,0.6)

		_ShadowFadePow("Shadow attenuate pow",Range(0.01, 2)) = 0.3

		[HideInInspector]_ShadowInvLen("Shadow InvLen",float) = 0.2
		[HideInInspector]_WorldPos("WorldPos",Vector) = (0,0,0,0)
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
		UsePass "HeroGo/PlaneShadow/PLANESHADOW"
	}
	FallBack "HeroGo/General/OneDirLight/Bumped"
}
