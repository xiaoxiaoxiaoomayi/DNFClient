Shader "HeroGo/ShadowPBR/Outline"
{
	Properties
	{
		_Albedo ("主纹理贴图", 2D) = "white" {}
		_Bump ("法线贴图", 2D) = "white" {}
		_Param("高光贴图", 2D) = "white" {}
		_LitSphere("反射环境图", 2D) = "white" {}

		_LightDir("灯光方向及强度", Vector) = (0, 0, 1, 1)
		_LightStrength("灯光强度", Range(0, 3)) = 1
		_ShadowCol("阴影颜色", Color) = (0, 0, 0, 0)

		_MainCol("主纹理颜色", Color) = (1, 1, 1, 1)
		_Metal("金属度", Range(0, 1)) = 1
		_Rough("粗糙度", Range(0, 1)) = 1

		_SpeCol("高光颜色", Color) = (1, 1, 1, 1)
		_SpeStrength("高光强度", Range(0, 8)) = 1
		_SpeCloth("衣服高光强度", Range(0, 0.3)) = 0
		
		[Toggle(_SSS)] _SSS("是否使用真实皮肤效果", Int) = 0
		_FresnelOffset("皮肤Fresnel偏移", Range(0, 6)) = 1
		_FresnelCol("皮肤半透颜色", Color) = (0.868, 0.258, 0.258, 0)

		_SkinStrength("皮肤灯光强度", Range(0.5, 1.5)) = 1
		_SpeSkin("皮肤高光强度", Range(0, 0.2)) = 0

		[Toggle(_Env)] _Env("是否使用环境反射", Int) = 0
		_EnvStrength("环境反射强度", Range(0, 100)) = 20
		_EnvOffset("旋转环境反射图", Range(0, 10)) = 8

		[Toggle(_Glow)] _Glow("是否使用自发光", Int) = 0
		_GlowCol("自发光颜色", Color) = (0, 0, 0, 1)
		_GlowStrength("自发光强度", Range(0, 20)) = 0

		[Toggle(_Blinking)] _Blinking("是否使用闪烁", Int) = 0
		_TimeOnDuration("闪烁时亮着的时间", Float) = 0.2
		_TimeOffDuration("闪烁时暗着的时间", Float) = 0.5
		_BlinkingTimeOffsScale("闪烁的开始位置", Float) = 5
		_NoiseAmount("闪烁时噪声的程度", Range(0, 1)) = 0.15

		[Toggle(_ColChange)] _ColChange("颜色类型1", Int) = 0
		_ColEffect("颜色类型选择", Range(0, 1)) = 0

		//OUTLINE
		_ScaleTimeLen("Scale time length", Range(0, 10)) = 0.23333331
		_ScaleWidth("Scale width", Range(1, 10)) = 3.5
		_BeginScale("Begin Scale", Range(0, 10)) = 3
		_Outline("Outline Width", Range(0.0, 0.01)) = 0.001
		_OutlineColorBegin("Begin Outline Color", Color) = (1.0, 0.0, 0.0, 1)
		_OutlineColorEnd("End Outline Color", Color) = (1.0, 1.0, 0.0, 1)
		[HideInInspector]_ElapsedTime("Elapsed time", Float) = 0
		[HideInInspector]_WorldRefPos("World ref position", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "LightMode" = "ForwardBase"
		       "Queue" = "Transparent" 
			   "RenderType" = "Transparent"
			   
		}
		LOD 100		
		Pass
		{
		    Cull Back
		    Zwrite On
			ZTest On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			#pragma multi_compile _ _SSS
			#pragma multi_compile _ _Env
			#pragma multi_compile _ _ColChange
			#pragma multi_compile _ _Glow
			#pragma multi_compile _ _Blinking
			#pragma target 2.0

			struct appdata
			{
				float4 vertex    : POSITION;
				float2 uv        : TEXCOORD0;
				half3 normal	 : NORMAL;
			    half4 tangent    : TANGENT;
			};

			struct v2f
			{				
				float4 position   : SV_POSITION;
				float3 uv         : TEXCOORD0;
				half3 normal      : TEXCOORD1;
				half3 tangent     : TEXCOORD2;
				half3 binormal    : TEXCOORD3;
				half3 viewDir     : TEXCOORD4;
				half3 lightDir    : TEXCOORD5;
			};

			sampler2D _Albedo;
			sampler2D _Bump;
			sampler2D _Param;
			sampler2D _LitSphere;
			half3 _LightDir;
			half _LightStrength;
			fixed4 _ShadowCol;
			fixed3 _MainCol; 
			half _Metal;
			float _Rough;
			fixed3 _SpeCol;
			half _SpeStrength;
			fixed _SpeCloth;			
			half _FresnelOffset;
			fixed3 _FresnelCol;
			fixed _SkinStrength;
			fixed _SpeSkin;
			half _EnvStrength;
			half _EnvOffset;
			fixed3 _GlowCol; 
			half _GlowStrength;
			fixed _ColEffect;

			float _TimeOnDuration;
			float _TimeOffDuration;
			float _BlinkingTimeOffsScale;
			float _NoiseAmount;

	v2f vert (appdata v)
	{
		v2f o;
		o.uv.xy = v.uv;
        //wordPos
		o.position = UnityObjectToClipPos(v.vertex);
		float4 worldPositon = mul(unity_ObjectToWorld, v.vertex);

		//Normal Tangent BiNormal
		half3 worldNormal = UnityObjectToWorldNormal(v.normal);  
		half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
		half sign = v.tangent.w * unity_WorldTransformParams.w;
		half3 worldBinormal = cross(worldNormal, worldTangent) * sign;
				o.normal = worldNormal;
				o.tangent = worldTangent;
				o.binormal = worldBinormal;

		//viewVector(计算视角方向）
		half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPositon.xyz);

		//WorldLightDir
		half3 lightDir = normalize(-_LightDir.xyz);
		o.viewDir = viewDir;
		o.lightDir.xyz = lightDir.xyz;

	 #ifdef _Blinking
		//自发光闪烁
		float time = _Time.y + _BlinkingTimeOffsScale;
		float fracTime = fmod(time, _TimeOnDuration + _TimeOffDuration);
		float wave = smoothstep(0, _TimeOnDuration * 0.25, fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75, _TimeOnDuration, fracTime));
		float noiseTime = time * (6.2831853 / _TimeOnDuration);
		float noise = (sin(noiseTime) + 1) * (0.5 * cos(noiseTime * 0.6366 + 56.7272) + 0.5);
		float noiseWave = _NoiseAmount * noise + (1 - _NoiseAmount);
		wave = _NoiseAmount < 0.01 ? wave : noiseWave;
		o.uv.z = wave;
     #else
	    o.uv.z = 1;
     #endif

		return o;
		}
			
	half4 frag (v2f i) : SV_Target
	{
		//WorldNormal 
		fixed4 normalMap = tex2D(_Bump, i.uv.xy);
		half3 worldNormal = UnpackNormal(normalMap); 
		half3 Nn = i.normal;
		half3 Tn = i.tangent;
		half3 Bn = i.binormal;
			  worldNormal = Nn * worldNormal.z + worldNormal.x * Tn + worldNormal.y * Bn;
			  worldNormal = normalize(worldNormal);		

	    //Reflection
		half nv = saturate(dot(worldNormal, i.viewDir));
		//LightPos
		half lightVec = dot(worldNormal, i.lightDir.xyz);
		half nl = saturate(lightVec);

		//基础色
		fixed4 albedoCol = tex2D(_Albedo, i.uv.xy);
		fixed3 mainColor = albedoCol.xyz * _MainCol;//基础色
		fixed3 baseCol = mainColor * mainColor;

		//贴图采样
		fixed4 mixTex = tex2D(_Param, i.uv.xy);
		float roughTex = mixTex.x * _Rough;//粗糙度图
		half metalTex = mixTex.y * _Metal;//金属度图
		fixed OCC = mixTex.z;//OCC图
		fixed skinPass = albedoCol.w; //皮肤通道
		fixed emisivePass = mixTex.w;//自发光通道

		//高光计算	
		float roughTexX2 = roughTex * roughTex;	
		float roughTexX4 = roughTexX2 * roughTexX2;
        float edgeSpec = nl * (roughTexX4 - 1);
			 edgeSpec = edgeSpec * nl + 1;
             edgeSpec = edgeSpec * edgeSpec;
			 edgeSpec = max(edgeSpec, 0.00000012);
        float baseSpec = roughTexX4 / edgeSpec;//高光聚散
		half reflctLight = nv * lightVec;//高光基础方向
		float roughSpread = reflctLight + edgeSpec;
             roughSpread = 0.25 / roughSpread;
        float specLight = baseSpec * roughSpread;//第一高光

        //金属高光带颜色		
	    fixed3 metalSpecColor = mainColor * baseCol;	
		fixed  notMetalSpec = lerp(_SpeCloth, _SpeSkin, skinPass);
		half3 specColor = lerp(notMetalSpec, metalSpecColor, metalTex);//高光强度分层控制
		half3 firstSpec = nl * specLight * specColor;
			  firstSpec = firstSpec * _SpeCol * _SpeStrength;//高光整体颜色强度

		//环境遮罩（OCC）
		half occlusion = OCC + (1 - nv);
			 occlusion = abs(lightVec) + occlusion;//OCC根据光方向阴影部分显示
			 occlusion = occlusion - 0.45;
			 occlusion = saturate(occlusion);

		//阴影计算
		half shadow = lightVec * occlusion;//灯光阴影过度叠加OCC的细节	
		half shadowBright = max(shadow, _ShadowCol.w);
		//fixed3 shadowColor = lerp(_LightDir.w * lightVec + _ShadowCol.xyz, 1, shadowBright);
		half3 shadowColor = lerp(_ShadowCol.xyz, 1, shadowBright);

		#ifdef _SSS
		//皮肤fresnel半透移偏 12
			  shadowColor = lerp(shadowColor, shadow, skinPass);
		half skinTrans = skinPass * _FresnelOffset;
		half3 skinColor = skinTrans * _FresnelCol;//控制皮肤阴影颜色强度
			  skinColor = (skinColor + shadowColor) / (skinColor + 1);//计算皮肤阴影/偏移效果
			  skinColor = max(skinColor, 0);
			  //skinColor = skinColor * 1.78 + occlusion * 0.20;//经验系数
			   skinColor = skinColor * 1.78;//经验系数
		#else 
			//编译指令 4
			shadowColor = max(shadowColor, _ShadowCol.w);//阴影暗部限值
			half3 skinColor = shadowColor * 2;
		#endif

		//最终效果叠加
		half3 skinBridge = baseCol * lerp(1, _SkinStrength, skinPass);//皮肤明暗
		half3 notMatelCol = (1 - metalTex) * skinBridge;
		half3 mianCol = notMatelCol * skinColor;
			  mianCol = mianCol * _LightStrength;
	    half3 finalColor = firstSpec + mianCol;//高光加基础色

		//添加环境光 20	
		#ifdef _Env	
		//yxz 设置环境图沿Y轴拉伸（xyz沿Z轴向内拉伸）
		half3 reflctDir = reflect((-i.viewDir).yzx, worldNormal.yzx);
		//环境光反射简易算法
		half p = sqrt(_EnvOffset * (reflctDir.z + 1));
		half2 envTexUV = (float2(reflctDir.y, min(-reflctDir.x, reflctDir.x)) / p) + 0.5;
		fixed2x2 rotMat = fixed2x2(0.54, -0.84, 0.84, 0.54);
			   envTexUV = mul(rotMat, envTexUV);//旋转经纬图
		//环境反射
		half metalAlpha = roughTex * 14 - roughTexX2 * 7;//金属通道
  		half4 envTex = tex2Dlod(_LitSphere, float4(envTexUV, 0, metalAlpha));
		half3 envAttens = envTex.www * envTex.xyz * metalTex;//根据alpha通道 获取环境光光源明暗
              //envAttens = envAttens * envAttens;
              //envAttens = envAttens * 18.85;
		//添加环境反射
		half3 encReflec = envAttens * specColor;//环境反射 仅影响金属
			   encReflec = encReflec * _EnvStrength;//环境反射强度
			   finalColor = finalColor + encReflec;
		#endif  

		//颜色类型 7
		#ifdef _ColChange
	    half3 finalCol1 = finalColor * 2.51;
               finalCol1 = finalColor * finalCol1;
		half3 finalCol2 = finalColor * 2.43 + 0.59;
               finalCol2 = finalColor * finalCol2 + 0.14;
		half3 colorStyle = finalCol1 / finalCol2;//增加亮度 减少对比度
			   finalColor = lerp(colorStyle, finalColor, _ColEffect);//颜色类型过渡
		#endif

		//自发光 3
		#ifdef _Glow
		half3 emissive = emisivePass * _GlowStrength;
			   emissive = mainColor * emissive;
			   finalColor = emissive * _GlowCol * i.uv.z + finalColor;//叠加自发光
		#endif
		  
		finalColor = pow(finalColor, 0.417);//最终颜色处理 返回SRGB颜色类型
		finalColor = finalColor * 1.055 - 0.055;//颜色饱和度

	   
		half4 col = half4(finalColor, 1);
		return col;
			}
	ENDCG
		}
		Pass
		{
			Name "OUTLINE_DOWNGRADE"

			Cull Back
			Lighting Off
			Fog{ Mode Off }
			//ZTest On
			Blend SrcAlpha One
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 factor : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 ViewDir : TEXCOORD2;
			};

			half _Outline;
			half _ZSmooth;
			uniform fixed4 _OutlineColorBegin;
			uniform fixed4 _OutlineColorEnd;

			half _ElapsedTime;
			half _BeginScale;
			half _ScaleTimeLen;
			half _ScaleWidth;
			float4 _WorldRefPos;
			
			v2f vert(a2v v)
			{
				 v2f o;
				 o.factor.xy = saturate((_ScaleTimeLen - _ElapsedTime) / _ScaleTimeLen);
				 
				 //Correct Z artefacts
				 float4 pos = mul(unity_ObjectToWorld, v.vertex);
				 o.ViewDir = normalize(_WorldSpaceCameraPos - pos);
				 
				 pos.xyz -= _WorldRefPos;
				 pos.xyz *= (1.005 + o.factor.x * _BeginScale * half3(_ScaleWidth, 1, _ScaleWidth));
				 pos.xyz += _WorldRefPos;				
				 pos = mul(UNITY_MATRIX_V, pos);
				 
				 float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				 normal.z = _ZSmooth;
				 
				 //Camera-independent size
				 float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));				 				 

				 o.pos = mul(UNITY_MATRIX_P, pos);
				 o.normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0)));

				return o;
			}

			float4 frag(v2f IN) : COLOR
			{
				// Outline flash
				half3 color = lerp(_OutlineColorEnd, _OutlineColorBegin, IN.factor.x);
				half fresnel = 1.0 - saturate(dot(IN.normal, IN.ViewDir));

				return half4(pow(fresnel, 2) * color * 2, fresnel * 2);
			}
			ENDCG
		}
	}
	FallBack "HeroGo/ShadowPBR/General"
}
