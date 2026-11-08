// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.27 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.27;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:33163,y:32604,varname:node_4795,prsc:2|normal-2411-OUT,emission-2411-OUT,clip-9104-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:32115,y:32414,ptovrint:False,ptlb:diffuse,ptin:_diffuse,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2393,x:32368,y:32593,varname:node_2393,prsc:2|A-6074-RGB,B-797-RGB;n:type:ShaderForge.SFN_Color,id:797,x:32115,y:32616,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Vector1,id:9248,x:32357,y:32768,varname:node_9248,prsc:2,v1:3;n:type:ShaderForge.SFN_Multiply,id:2411,x:32674,y:32620,varname:node_2411,prsc:2|A-2393-OUT,B-9248-OUT;n:type:ShaderForge.SFN_Multiply,id:9104,x:32861,y:32889,varname:node_9104,prsc:2|A-4850-OUT,B-3642-OUT;n:type:ShaderForge.SFN_Tex2d,id:3462,x:32248,y:32856,ptovrint:False,ptlb:noise,ptin:_noise,varname:node_3462,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:7995,x:32224,y:33072,ptovrint:False,ptlb:size,ptin:_size,varname:node_7995,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.4028185,max:1;n:type:ShaderForge.SFN_Vector1,id:7913,x:32285,y:33153,varname:node_7913,prsc:2,v1:3;n:type:ShaderForge.SFN_Multiply,id:3642,x:32568,y:33097,varname:node_3642,prsc:2|A-7995-OUT,B-7913-OUT;n:type:ShaderForge.SFN_Vector1,id:7089,x:32495,y:32979,varname:node_7089,prsc:2,v1:3;n:type:ShaderForge.SFN_Multiply,id:4850,x:32663,y:32888,varname:node_4850,prsc:2|A-3462-A,B-7089-OUT;n:type:ShaderForge.SFN_TexCoord,id:5659,x:32063,y:32618,varname:node_5659,prsc:2,uv:0;proporder:6074-797-3462-7995;pass:END;sub:END;*/

Shader "Shader Forge/rongjie_add" {
    Properties {
        _diffuse ("diffuse", 2D) = "white" {}
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _noise ("noise", 2D) = "white" {}
        _size ("size", Range(0, 1)) = 0.4028185
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _diffuse; uniform float4 _diffuse_ST;
            uniform float4 _TintColor;
            uniform sampler2D _noise; uniform float4 _noise_ST;
            uniform float _size;
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
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float4 _diffuse_var = tex2D(_diffuse,TRANSFORM_TEX(i.uv0, _diffuse));
                float3 node_2411 = ((_diffuse_var.rgb*_TintColor.rgb)*3.0);
                float3 normalLocal = node_2411;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float4 _noise_var = tex2D(_noise,TRANSFORM_TEX(i.uv0, _noise));
                clip(((_noise_var.a*3.0)*(_size*3.0)) - 0.5);
////// Lighting:
////// Emissive:
                float3 emissive = node_2411;
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, finalRGBA, fixed4(0,0,0,1));
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
