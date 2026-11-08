// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.27 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.27;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32522,y:32572,varname:node_4795,prsc:2|emission-4854-OUT,clip-815-OUT;n:type:ShaderForge.SFN_Tex2d,id:1853,x:31824,y:32393,ptovrint:False,ptlb:diffuse,ptin:_diffuse,varname:node_1853,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:929,x:32049,y:32457,varname:node_929,prsc:2|A-1853-RGB,B-3638-RGB;n:type:ShaderForge.SFN_Color,id:3638,x:31806,y:32607,ptovrint:False,ptlb:blend,ptin:_blend,varname:node_3638,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4854,x:32325,y:32587,varname:node_4854,prsc:2|A-929-OUT,B-2644-OUT;n:type:ShaderForge.SFN_Vector1,id:2644,x:32148,y:32608,varname:node_2644,prsc:2,v1:5;n:type:ShaderForge.SFN_Slider,id:4462,x:31717,y:33008,ptovrint:False,ptlb:node_4462,ptin:_node_4462,varname:node_4462,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Tex2d,id:6073,x:31848,y:32799,ptovrint:False,ptlb:alpha,ptin:_alpha,varname:node_6073,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3706,x:32074,y:32830,varname:node_3706,prsc:2|A-6073-A,B-4462-OUT;n:type:ShaderForge.SFN_Multiply,id:815,x:32305,y:32830,varname:node_815,prsc:2|A-3706-OUT,B-8683-OUT;n:type:ShaderForge.SFN_Vector1,id:8683,x:32177,y:32938,varname:node_8683,prsc:2,v1:2;n:type:ShaderForge.SFN_TexCoord,id:1110,x:32127,y:32682,varname:node_1110,prsc:2,uv:0;proporder:1853-3638-4462-6073;pass:END;sub:END;*/

Shader "Shader Forge/rongjie_blend" {
    Properties {
        _diffuse ("diffuse", 2D) = "white" {}
        _blend ("blend", Color) = (0.5,0.5,0.5,1)
        _node_4462 ("node_4462", Range(0, 1)) = 1
        _alpha ("alpha", 2D) = "white" {}
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
            Blend SrcAlpha OneMinusSrcAlpha
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
            uniform float4 _blend;
            uniform float _node_4462;
            uniform sampler2D _alpha; uniform float4 _alpha_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _alpha_var = tex2D(_alpha,TRANSFORM_TEX(i.uv0, _alpha));
                clip(((_alpha_var.a*_node_4462)*2.0) - 0.5);
////// Lighting:
////// Emissive:
                float4 _diffuse_var = tex2D(_diffuse,TRANSFORM_TEX(i.uv0, _diffuse));
                float3 emissive = ((_diffuse_var.rgb*_blend.rgb)*5.0);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
