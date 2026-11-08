Shader "HeroGo/Surface/Ice" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _MaskTex ("Mask Tex", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
        _EnvMap ("Environment Map", 2D) = "gras" {}
        _Intensity("Light Intensity",Range(0, 2)) = 1
		_NorIn ("Normal Intensity", Range(0, 1)) = 1
		_opaquen ("Opaqueness", Range(0, 1)) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            //ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 2.0

             sampler2D _NormalMap;
             sampler2D _MainTex; 
             sampler2D _MaskTex;
             sampler2D _EnvMap;
             fixed4 _MainColor;
             fixed _Intensity;

			 fixed _NorIn;
             fixed _opaquen;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 viewDirection : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);

                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.viewDirection.xyz = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
                o.pos = UnityObjectToClipPos( v.vertex );
                float3 lightDirection = float3(0, 0.707, -0.707);
                float3 halfDirection = normalize(o.viewDirection + lightDirection);
                float blinnPhong = max(0, dot(o.normalDir, halfDirection)); // Blinn-Phong
                float4 remap = float4(0.95, 1, 0, 0.5);
                blinnPhong = saturate((blinnPhong - remap.x) / (remap.y - remap.x) * (remap.w - remap.z) + remap.z);
                o.viewDirection.w = blinnPhong;
                return o;
            }
            fixed4 frag(VertexOutput i) : SV_Target {
                float blinnPhong = i.viewDirection.w;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);

                fixed3 normalLocal = UnpackNormal(tex2D(_NormalMap, i.uv0));
                normalLocal.xy *= _NorIn;
                float3 normalDirection = normalize(mul( normalLocal.xyz, tangentTransform )); // Perturbed normals
                fixed2 nsUV = mul( UNITY_MATRIX_V, float4( normalDirection, 0 ) ).rg * 0.5 + 0.5; // normalSpaceUV
                fixed4 EnvTexVar = tex2D( _EnvMap, nsUV );

                fixed4 c;
                fixed4 MainTexVar = tex2D( _MainTex, i.uv0 );
                fixed4 MaskTexVar = tex2D( _MaskTex, i.uv0 );

                EnvTexVar += saturate(EnvTexVar * 1.5 - 1) * MaskTexVar.g;
                EnvTexVar *= _Intensity;

                c.rgb = lerp(MainTexVar, EnvTexVar.rgb, MaskTexVar.g);
                c.rgb = c.rgb * _MainColor.rgb;
                fixed spe = blinnPhong * c.rgb * 3 * (MaskTexVar.r * 0.5 + 0.5);
                fixed3 specular = spe * MainTexVar.rgb * EnvTexVar.rgb * 3;
                c.rgb += specular;

                fixed Transparency = abs(i.uv0.g - 0.5) * 0.5 + 0.25;
                fixed TranRange = (dot(EnvTexVar.rgb, float3(0.3, 0.59, 0.11)) - Transparency) / 0.5; // TransparencyRange
                float Fresnel = 1.0 - dot(normalDirection, i.viewDirection.xyz);
                c.a = saturate(max(TranRange, Fresnel) + MaskTexVar.b) * saturate(MaskTexVar.b + 0.5);
                c.a = 1 - MaskTexVar.g + c.a * MaskTexVar.g;
                c.a = saturate(c.a + _opaquen);
                return c;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
