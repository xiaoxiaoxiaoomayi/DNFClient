// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/UI/Particles_Additive"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	
		//-------------------add----------------------
		[HideInInspector]_MinX ("Min X", Float) = -10
		[HideInInspector]_MaxX ("Max X", Float) = 10
		[HideInInspector]_MinY ("Min Y", Float) = -10
		[HideInInspector]_MaxY ("Max Y", Float) = 10
		 //-------------------add----------------------
	}
	
	SubShader
	{

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Blend SrcAlpha One
		AlphaTest Greater .01
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off Fog{ Color(0,0,0,0) }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
 
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
 
			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD1;
				#endif
				//-------------------add----------------------
				float4 vpos : TEXCOORD2;
				//-------------------add----------------------
				float4 Min : TEXCOORD3;
				float4 Max : TEXCOORD4;
			};

			//-------------------add----------------------
			float _MinX;
			float _MaxX;
			float _MinY;
			float _MaxY;
			//-------------------add----------------------

			float4 _MainTex_ST;
			v2f vert (appdata_t v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vpos = ComputeScreenPos (o.vertex);

				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif

				o.Min = ComputeScreenPos(mul(UNITY_MATRIX_VP, half4(_MinX, _MinY, 1.0f, 1.0f)));
				o.Max = ComputeScreenPos(mul(UNITY_MATRIX_VP, half4(_MaxX, _MaxY, 1.0f, 1.0f)));

				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			sampler2D _MainTex;
			fixed4 _TintColor;

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : SV_Target
			{
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.vpos)));
				float partZ = i.vpos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif

				fixed4 c =2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				//-------------------add----------------------
				c.a *= (i.vpos.x >= i.Min.x);
				c.a *= (i.vpos.x <= i.Max.x);
				c.a *= (i.vpos.y >= i.Min.y);
				c.a *= (i.vpos.y <= i.Max.y);
                //-------------------add----------------------

				c.rgb *= c.a;
                return c;
			}
			ENDCG 
		}
	}	
}