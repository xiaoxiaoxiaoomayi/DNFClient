// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Selfmade/TransparentShadowReceiver" 
{ 
 
Properties 
{ 
 	// Usual stuffs
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) TransGloss (A)", 2D) = "white" {} 
	// Shadow Stuff
	_ShadowIntensity ("Shadow Intensity", Range (0, 1)) = 0.6
} 
 
 
SubShader 
{ 
	Tags {
	"Queue"="AlphaTest" 
	"IgnoreProjector"="True" 
	"RenderType"="Transparent"
	}
 
	LOD 300
 
		// Shadow Pass : Adding the shadows (from Directional Light)
		// by blending the light attenuation
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha 
			Name "ShadowPass"
			Tags {"LightMode" = "ForwardBase"}
 
			CGPROGRAM 
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members lightDir)
#pragma exclude_renderers d3d11 xbox360
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_fog_exp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
 
			struct v2f { 
				float2 uv_MainTex : TEXCOORD0;
				float4 pos : SV_POSITION;
				LIGHTING_COORDS(1,2)
			};
 
			float4 _MainTex_ST;
 
			sampler2D _MainTex;
			float4 _Color;
			float _ShadowIntensity;
 
			v2f vert (appdata_base v)
			{
				v2f o;
                o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.pos = UnityObjectToClipPos (v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
 
			float4 frag (v2f i) : COLOR
			{
				float atten = SHADOW_ATTENUATION(i);
				half4 c;
				c =  tex2D(_MainTex, i.uv_MainTex);
                c.rgb = c.rgb * atten;
				return c;
			}
			ENDCG
		}
 
 
}
 
FallBack "Transparent/Cutout/VertexLit"
}