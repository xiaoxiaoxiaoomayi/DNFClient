Shader "HeroGo/Effect/VertexOffset" 
{
    Properties 
	{
        [Enum(Alpha Blend,10,Addtive,1)] _DestBlend("Dest Blend Mode", Float) = 1
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_VertexTex01 ("Vertex Texture 01", 2D) = "white" {}
        _ASpeedU ("A Speed U", Float ) = 0
        _ASpeedV ("A Speed V", Float ) = 0
        _VertexTex02 ("Vertex Texture 02", 2D) = "white" {}
        _BSpeedU ("B Speed U", Float ) = 0
        _BSpeedV ("B Speed V", Float ) = 0        
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
		Blend SrcAlpha [_DestBlend], [_SrcAlphaFactor] [_DestBlend]
		Cull Off
		ZWrite Off

        Pass {
		                       
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0

            fixed4 _MainColor;
            float _ASpeedU;
            float _ASpeedV;
            sampler2D _VertexTex01; 
			float4 _VertexTex01_ST;
            sampler2D _VertexTex02; 
			float4 _VertexTex02_ST;
            float _BSpeedU;
            float _BSpeedV;
            sampler2D _MainTex;
			float4 _MainTex_ST;

            struct VertexInput 
			{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                fixed4 vertexColor : COLOR;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                fixed4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                float2 vertUV01 = float2((_ASpeedU * _Time.g + o.uv0.r),(o.uv0.g + _Time.g * _ASpeedV ));
                fixed4 vertColor01 = tex2Dlod(_VertexTex01,float4(TRANSFORM_TEX(vertUV01, _VertexTex01),0.0,0));
                float2 vertUV02 = float2((_BSpeedU * _Time.g + o.uv0.r), (o.uv0.g + _Time.g * _BSpeedV));
                fixed4 vertColor02 = tex2Dlod(_VertexTex02, float4(TRANSFORM_TEX(vertUV02, _VertexTex02),0.0,0));
                v.vertex.xyz += vertColor01.rgb * vertColor02.rgb * v.normal * o.uv1.r;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            fixed4 frag(VertexOutput i) : COLOR 
			{
                fixed4 mainColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed3 finalColor = (_MainColor.rgb * mainColor.rgb * i.vertexColor.rgb * i.vertexColor.a);
                return fixed4(finalColor, i.vertexColor.a * mainColor.a);
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
