// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/General/UnLit/HG_Unlit_ColorGrading_Opaque"
{
	Properties
	{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_GradingTex("Grading (RGB) Trans (A)", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 100

		Cull Back
		ZWrite On
		ZTest On
		Blend Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			sampler2D _GradingTex;
			float4 _MainTex_ST;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				UNITY_APPLY_FOG(i.fogCoord, col);

				/// color grading phase
				const half4 coord_scale = half4(0.0302734375, 0.96875, 31.0, 0.0);
				const half4 coord_offset = half4(0.00048828125, 0.015625, 0.0, 0.0);
				const half2 texel_height_X0 = half2(0.03125, 0.0);

				half3 coord = col * coord_scale + coord_offset;
				
				half3 coord_floor = floor(coord + 0.5);
				half2 coord_bot = coord.xy + coord_floor.zz * texel_height_X0;
				
				col.rgb = tex2D(_GradingTex, coord_bot).rgb;

				return col;
			}
			ENDCG
		}
	}

}
