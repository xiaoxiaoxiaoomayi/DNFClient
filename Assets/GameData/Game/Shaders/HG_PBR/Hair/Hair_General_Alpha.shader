Shader "HeroGo/Hair/General_Alpha" {
    Properties {
		[Header(BRDF Controller)]
		_BrightColor ("Bright Color", Color) = (1, 1, 1, 1)
        _BrightColorOffset ("Bright Color Offset", Range(-1, 1)) = 0
        _BrightColorSharpen ("Bright Color Sharpen", Range(1, 10)) = 1
        _BrightEdge ("Bright Edge", Color) = (0, 0, 0, 1)
        _BrightEdgeOffset ("Bright Edge Offset", Range(-1, 1)) = 0
        _BrightEdgeSharpen ("Bright Edge Sharpen", Range(1, 10)) = 1
        _DarkColor ("Dark Color", Color) = (0, 0, 0, 1)
        _DarkOffset ("Dark Color Offset", Range(-1, 1)) = 0
        _DarkSharpen ("Dark Color Sharpen", Range(1, 10)) = 1
        _DarkEdge ("Dark Edge", Color) = (0, 0, 0, 1)
        _DarkEdgeOffset ("Dark Edge Offset", Range(-1, 1)) = 0
        _DarkEdgeSharpen ("Dark Edge Sharpen", Range(1, 10)) = 1
		[Header(_________________________________________________________________________)]
        _Color ("Color", Color) = (1,1,1,1)
        _Albedo ("Albedo", 2D) = "white" {}
        _Bump ("Bump (RGB)", 2D) = "bump" {}
        _Param ("Glossy (RGB) R:Metallic G:Smoothness B:Ambient Occlusion", 2D) = "white" {}
		_Spe_Intensity ("Spe_Intensity", Range(0, 1)) = 0.5
		[Header(_________________________________________________________________________)]
		_Alphafactor ("Alpha factor", Range(0, 1)) = 0.6
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }

    SubShader {
        Tags {
            "Queue"="Transparent"
			"RenderType"="Transparent"
        }
        	LOD 100
			Cull Back
			Zwrite On
			Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            Name "General_Alpha"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"
            #pragma target 2.0
			#pragma multi_compile _ USE_EMISSION
			#pragma multi_compile _ EMISSION_GRADUAL
			
			 fixed4 _BrightColor;
             fixed4 _BrightEdge;
             fixed4 _DarkEdge;
             fixed4 _DarkColor;
             fixed _DarkEdgeOffset;
             fixed _DarkEdgeSharpen;
             fixed _DarkOffset;
             fixed _DarkSharpen;
             fixed _BrightColorOffset;
             fixed _BrightColorSharpen;
             fixed _BrightEdgeOffset;
             fixed _BrightEdgeSharpen;
			 fixed _Spe_Intensity;

             fixed4 _Color;
             sampler2D _Albedo;  
             sampler2D _Bump;  
             sampler2D _Param;  
			 float4 _LightColor0;

			 fixed _Alphafactor;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
				
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
				float3 viewDirection : TEXCOORD5;
				float3 lightDirection : TEXCOORD6;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
				UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv0 = v.texcoord0;
                o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
                o.lightDirection = normalize(o.viewDirection + float3(-0.5, 1, -0.3));//normalize(_WorldSpaceLightPos0.xyz);
                return o;
            }
			
			fixed3 NormalDirection(fixed3 normalMap, fixed3 normalDir, fixed3 tangentDir, fixed3 bitangentDir){
				float3x3 tangentTransform = float3x3(tangentDir, bitangentDir, normalDir);
                return normalize(mul( normalMap, tangentTransform )); // Perturbed normals
			}

			fixed halfOptimize(fixed3 A, fixed3 B){
				return max(0.0, dot(A, B)) * 0.5 + 0.5;
			}

			fixed3 brdfModule(fixed2 brdfSpace, fixed2 position, fixed brdfOffset, fixed brdfSharpen, fixed3 col){
				fixed brdfRange = 1.0 - length(brdfSpace + position) + brdfOffset;
				brdfRange = brdfRange * brdfSharpen + 0.5 * (1 - brdfSharpen);
				return col * max(0.0, brdfRange);
			}
			
			fixed pow4(fixed x){
				return x * x * x * x;
			}

            fixed4 frag(VertexOutput i) : SV_Target {
                fixed4 mainTex = tex2D(_Albedo, i.uv0);
                fixed4 glossy = tex2D(_Param, i.uv0);
				fixed3 normalMap = UnpackNormal(tex2D(_Bump, i.uv0));
				normalMap = fixed3(0, 0, 0.6) + normalMap * 0.4;
				fixed ao = pow4(glossy.b);
				normalMap.g = normalMap.g * (1-glossy.r * ao) * 2;
				normalMap.r = normalMap.r * glossy.r * ao * 2;
                fixed3 normalDir = NormalDirection(normalMap, i.normalDir, i.tangentDir, i.bitangentDir); // Perturbed normals
				fixed VdotN = dot(i.viewDirection, normalDir);
				fixed3 viewReflectDirection = -i.viewDirection + 2 * VdotN * normalDir;
				fixed Glossing = 1.0 - glossy.g;

		// Diffuse---<
				fixed3 diffuseColor = mainTex.rgb * _Color.rgb; 
				fixed2 brdfSpace = float2(halfOptimize(i.lightDirection, normalDir), halfOptimize(i.viewDirection, normalDir));
				fixed3 brightBRDF = brdfModule(brdfSpace, float2(-1, -1), _BrightColorOffset, _BrightColorSharpen, _BrightColor.rgb);
				fixed3 brEdBRDF = brdfModule(brdfSpace, float2(-1,  0), _BrightEdgeOffset, _BrightEdgeSharpen, _BrightEdge.rgb);
				fixed3 darkBRDF = brdfModule(brdfSpace, float2( 0, -1), _DarkOffset, _DarkSharpen, _DarkColor.rgb);
				fixed3 daEdBRDF = brdfModule(brdfSpace, float2( 0,  0), _DarkEdgeOffset, _DarkEdgeSharpen, _DarkEdge.rgb);
                fixed3 finalBRDF = brightBRDF + brEdBRDF + darkBRDF + daEdBRDF; // BRDF
                fixed3 diffuseCol = finalBRDF * diffuseColor;
			//--->	

		// Specular ---<
                fixed3 simulationLig = float3(0, -1, 0);
                fixed LdotV = dot(simulationLig, viewReflectDirection);
                fixed speHeight = 0.45;
                fixed VRdotN = dot(viewReflectDirection, normalDir);
                fixed mainAnisotropy = 1.0 - saturate(abs(LdotV + speHeight));
				fixed highAnisotropy = saturate(mainAnisotropy * 2 - 1);
				highAnisotropy *= highAnisotropy;
                mainAnisotropy = mainAnisotropy * mainAnisotropy * (1 - VRdotN) + highAnisotropy * VRdotN * 0.3;

                fixed middleMask = 1 - abs(dot(simulationLig, normalDir) + speHeight);
                middleMask *= middleMask;
                middleMask += middleMask;
                middleMask = saturate(middleMask);

                fixed edgeMask = saturate(VRdotN * 2.5 - 2.0);
                edgeMask += VRdotN + 0.2;
                edgeMask *= _Spe_Intensity;

                fixed anisotropyLig = mainAnisotropy * middleMask * edgeMask * ao;
			//--->

                fixed3 finalColor = diffuseCol + anisotropyLig;

                return fixed4(finalColor, _Alphafactor);
            }
            ENDCG
        }
    }
    FallBack "HeroGo/Hair/General"
}
