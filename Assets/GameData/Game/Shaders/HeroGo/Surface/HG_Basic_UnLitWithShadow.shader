// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Toony Colors Pro+Mobile Shaders
// (c) 2013, Jean Moreno

Shader "HeroGo/General/UnLit/UnLitWithShadow"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//COLORS
		_Color ("Texture Color", Color) = (1,1,1,1)
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		Pass
		{
			Lighting On
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			//#pragma exclude_renderers d3d11 xbox360
			#pragma vertex vert
			#pragma fragment frag


			#include "UnityCG.cginc"

			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "AutoLight.cginc"



			// If you really want separate shadow and falloff values, uncomment the commented out lines below - the ones starting with //

			// As Unity Free only supports shadows from one directional light anyway, there's no real need as directional lights have no falloff.

			//#include "CustomLight.cginc"

			float4 _Color;
			sampler2D _MainTex;
			uniform float4 _MainTex_ST;	
			
			struct appdata 
			{
				float4 vertex   :   POSITION;
				fixed4 color	:   COLOR;
			};



			struct v2f 
			{
				float4  pos     :   SV_POSITION;
				float2  uv      :   TEXCOORD0;
				LIGHTING_COORDS(1, 2) // This tells it to put the vertex attributes required for lighting into TEXCOORD1 and TEXCOORD2.
			};



			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv =  TRANSFORM_TEX(v.texcoord, _MainTex);
				TRANSFER_VERTEX_TO_FRAGMENT(o) // This sets up the vertex attributes required for lighting and passes them through to the fragment shader.
				return o;
			}



			fixed4 frag(v2f i) : COLOR
			{
				//fixed atten = LIGHT_ATTENUATION(i); // This gets the shadow and attenuation values combined.
				//fixed falloff = LIGHT_FALLOFF(i); // This is a custom one to get just the attenuation value. Requires CustomLight.cginc to be included.
				half4 texcol = tex2D(_MainTex, i.uv);
				fixed shadow = SHADOW_ATTENUATION(i); // This is gets just the shadow value - it's basically a fixed precision float where 1 is in light and 0 is in shadow.

				fixed4 c = texcol;
				c.rgb = c.rgb * shadow;
				return c;
			}

			ENDCG
		}
	}
	Fallback "VertexLit"
}
