// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.27 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.27;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:32719,y:32712,varname:node_4013,prsc:2|diff-5076-OUT,spec-1808-OUT,gloss-5143-OUT,normal-9698-RGB,amspl-6612-OUT;n:type:ShaderForge.SFN_Tex2d,id:1656,x:31648,y:32071,ptovrint:False,ptlb:node_4169,ptin:_node_4169,varname:_node_4169,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:3c16aa7b62019374897aed6d17fb19c9,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:9698,x:32258,y:32958,ptovrint:False,ptlb:N,ptin:_N,varname:_N,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0d2a1645133fb0f49994733552e1bae9,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Color,id:7824,x:31705,y:32363,ptovrint:False,ptlb:node_6933,ptin:_node_6933,varname:_node_6933,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:2991,x:32112,y:32407,varname:node_2991,prsc:2|A-7824-RGB,B-1656-A;n:type:ShaderForge.SFN_Add,id:5076,x:32351,y:32316,varname:node_5076,prsc:2|A-1656-RGB,B-2991-OUT;n:type:ShaderForge.SFN_Tex2d,id:5472,x:31102,y:32619,ptovrint:False,ptlb:node_5472,ptin:_node_5472,varname:_node_5472,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:4b5b6346330f7a049963c5a11d63bbf9,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:1808,x:31608,y:32720,varname:node_1808,prsc:2|A-5472-RGB,B-7871-OUT;n:type:ShaderForge.SFN_LightVector,id:7871,x:31184,y:33066,varname:node_7871,prsc:2;n:type:ShaderForge.SFN_Multiply,id:2904,x:31752,y:33149,varname:node_2904,prsc:2|A-7871-OUT,B-9179-OUT;n:type:ShaderForge.SFN_Slider,id:9179,x:31113,y:33296,ptovrint:False,ptlb:Skylight,ptin:_Skylight,varname:_Skylight,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Cubemap,id:9971,x:31227,y:33569,ptovrint:False,ptlb:Specula IBL,ptin:_SpeculaIBL,varname:_SpeculaIBL,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,pvfc:0;n:type:ShaderForge.SFN_Multiply,id:4748,x:32039,y:33226,varname:node_4748,prsc:2|A-2904-OUT,B-9971-RGB;n:type:ShaderForge.SFN_Multiply,id:6612,x:32354,y:33216,varname:node_6612,prsc:2|A-4748-OUT,B-5330-OUT,C-7981-RGB;n:type:ShaderForge.SFN_Slider,id:5330,x:31686,y:33580,ptovrint:False,ptlb:fanshe,ptin:_fanshe,varname:_fanshe,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:3.126419,max:10;n:type:ShaderForge.SFN_Slider,id:5143,x:31936,y:32853,ptovrint:False,ptlb:gloss,ptin:_gloss,varname:_gloss,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Color,id:7981,x:32039,y:33673,ptovrint:False,ptlb:node_7981,ptin:_node_7981,varname:_node_7981,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:1656-7824-9698-5472-9179-9971-5330-5143-7981;pass:END;sub:END;*/

Shader "Shader Forge/Weapon" {
    Properties {
        _node_4169 ("node_4169", 2D) = "white" {}
        _node_6933 ("node_6933", Color) = (0.5,0.5,0.5,1)
        _N ("N", 2D) = "bump" {}
        _node_5472 ("node_5472", 2D) = "white" {}
        _Skylight ("Skylight", Range(0, 1)) = 1
        _SpeculaIBL ("Specula IBL", Cube) = "_Skybox" {}
        _fanshe ("fanshe", Range(0, 10)) = 3.126419
        _gloss ("gloss", Range(0, 10)) = 0
        _node_7981 ("node_7981", Color) = (0.5,0.5,0.5,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _node_4169; uniform float4 _node_4169_ST;
            uniform sampler2D _N; uniform float4 _N_ST;
            uniform float4 _node_6933;
            uniform sampler2D _node_5472; uniform float4 _node_5472_ST;
            uniform float _Skylight;
            uniform samplerCUBE _SpeculaIBL;
            uniform float _fanshe;
            uniform float _gloss;
            uniform float4 _node_7981;
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
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _N_var = UnpackNormal(tex2D(_N,TRANSFORM_TEX(i.uv0, _N)));
                float3 normalLocal = _N_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = _gloss;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float4 _node_5472_var = tex2D(_node_5472,TRANSFORM_TEX(i.uv0, _node_5472));
                float3 specularColor = (_node_5472_var.rgb*lightDirection);
                float3 directSpecular = (floor(attenuation) * _LightColor0.xyz) * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 indirectSpecular = (0 + (((lightDirection*_Skylight)*texCUBE(_SpeculaIBL,viewReflectDirection).rgb)*_fanshe*_node_7981.rgb))*specularColor;
                float3 specular = (directSpecular + indirectSpecular);
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _node_4169_var = tex2D(_node_4169,TRANSFORM_TEX(i.uv0, _node_4169));
                float3 diffuseColor = (_node_4169_var.rgb+(_node_6933.rgb*_node_4169_var.a));
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _node_4169; uniform float4 _node_4169_ST;
            uniform sampler2D _N; uniform float4 _N_ST;
            uniform float4 _node_6933;
            uniform sampler2D _node_5472; uniform float4 _node_5472_ST;
            uniform float _gloss;
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
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _N_var = UnpackNormal(tex2D(_N,TRANSFORM_TEX(i.uv0, _N)));
                float3 normalLocal = _N_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = _gloss;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float4 _node_5472_var = tex2D(_node_5472,TRANSFORM_TEX(i.uv0, _node_5472));
                float3 specularColor = (_node_5472_var.rgb*lightDirection);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float4 _node_4169_var = tex2D(_node_4169,TRANSFORM_TEX(i.uv0, _node_4169));
                float3 diffuseColor = (_node_4169_var.rgb+(_node_6933.rgb*_node_4169_var.a));
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
