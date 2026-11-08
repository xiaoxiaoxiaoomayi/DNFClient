// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Toony Colors Pro+Mobile Shaders
// (c) 2013, Jean Moreno

Shader "Hidden/HeroGo/PlaneShadow"
{
	Properties
	{
		_ShadowPlane("Shadow Plane", Vector) = (0,1,0,0)
		_ShadowPlaneColor("Shadow Color(RGB color A density)",Color) = (0.2,0.1,0.3,0.8)
		_ShadowFadePow("Shadow attenuate pow",Range(0.01, 2)) = 0.6
		_ShadowLightDir("Shadow Light Dir",Vector) = (-0.65,-1,0.5,0)

		[HideInInspector]_ShadowInvLen("Shadow InvLen",float) = 0.2
		[HideInInspector]_WorldRefPos("WorldPos",Vector) = (0,0,0,0)
	}
	
	SubShader
	{
		Tags 
		{ 
			"RenderType" = "Opeque"
			"LightMode" = "ForwardBase"
		}
		LOD 200
		
		//Outline default
		Pass
		{
			Name "PLANESHADOW"


			Cull Back
			Lighting Off
			ZWrite Off
            Fog { Mode Off }
            Stencil {
                Comp Equal
                Pass IncrWrap
            }
            
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f
			{
				float4 pos : POSITION;
                float3 worldpos  : TEXCOORD0;
                float4 shadowpos : TEXCOORD1;

			};
			
            float4 _ShadowPlane;
            float _ShadowFadePow;

            float _ShadowInvLen;

			fixed4 _ShadowPlaneColor;
            float4 _WorldRefPos;
            float4 _ShadowLightDir;

			v2f vert (a2v v)
			{
				v2f o;
				float4 shadowdir = -normalize(_ShadowLightDir);//-normalize(_WorldSpaceLightPos0);
	            float3 worldpos = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 shadowpos;
                
                shadowpos = (worldpos - ((
                                        (dot (_ShadowPlane.xyz, worldpos) - _ShadowPlane.w)
                                        / 
                                        dot (_ShadowPlane.xyz, shadowdir.xyz)
                                        ) * shadowdir.xyz));
                                       
                float4 pos;
                pos.w = 1.0;
                pos.xyz = shadowpos;
                o.pos = mul(UNITY_MATRIX_VP,pos);
                o.worldpos = _WorldRefPos.xyz;
                o.shadowpos.xyz = shadowpos;
				o.shadowpos.w = 1;
				//float3 normal = mul(_Object2World, v.normal);
				//o.shadowpos.w = dot(-shadowdir.xyz, normal);

  			    return o;
			}
			
			float4 frag (v2f IN) : COLOR
			{
                half3  posToPlane;
				posToPlane = IN.worldpos - IN.shadowpos;
                half4 shadowcolor;
                shadowcolor.xyz = _ShadowPlaneColor.xyz;
				shadowcolor.w = (1 -  pow(saturate(sqrt(dot(posToPlane, posToPlane)) * _ShadowInvLen ), _ShadowFadePow)) * _ShadowPlaneColor.w;
                return shadowcolor;
			}

			ENDCG
		}
	}
}
