Shader "Sprites/DirectionalDissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "white"{}
		_MeltPlane("Melt Plane", vector) = (0,1,0)
		_thickNess ("ThickNess", float) = 5
		_ColorLerp("ColorLerp", float) = 2
		_MeltProgress("Melt Progress", float) = 0
		_MeltEdgeColorBottom("Melt Edge Color Bottom", Color) = (1,1,1,1)
		_MeltEdgeColorTop("Melt Edge Color2 Top", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _thickNess;
			float _ColorLerp;
			float3 _MeltPlane;
			float _MeltProgress;
			float4 _MeltEdgeColorBottom;
			float4 _MeltEdgeColorTop;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.worldPos = v.vertex.xyz;
				o.color = v.color;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy); 

				half c = col.r * 0.3 + col.g * 0.52 + col.b * 0.18;
				col.r = col.g = col.b = c ;

				col *= i.color;

				// for the melt.
				fixed noise = tex2D(_NoiseTex, i.uv.zw).r;

				fixed height = saturate(dot(i.worldPos, _MeltPlane.xyz) * _thickNess + _MeltProgress);

				// ret step(y, x) = (x >= y) ? 1 : 0
				// fixed2 melt = step(saturate(height * (_MeltParams.xy)), iceCol.rr);
				fixed melt = (noise - height);
				clip(melt);

				fixed lerpValue = min(noise, height) * _ColorLerp;
				float3 lerpColor = lerp(_MeltEdgeColorBottom.rgb, _MeltEdgeColorTop.rgb, lerpValue);
				col.rgb = lerp(col.rgb, lerpColor.rgb, lerpValue);
				//col.a = lerp(col.a, 0, melt2*_MeltParams.y);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
