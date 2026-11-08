Shader "HeroGo/Cel/Surface/Tint"
{
	Properties
	{	    
		_MainTex ("Main Texture", 2D) = "white" {}
		_LightMapTex("Light Map",2D) = "white"{}

		//_Normal
		_NormalTex("Normal Texture", 2D) = "bump"{}
		_NormalValue ("Normal Value", Range(0,10)) = 0

		_MainColor("Main Color", Color) = (1, 1, 1, 1.0)
		_Intensity("Intensity", Range(0, 2)) = 1
		_LightArea("Light Area", Float) = 0.51
		_SecondShadow("Second Shadow", Float) = 0.51

		_FirstShadowMultColor("First Shadow Mult Clor", Color) = (1, 1, 1, 1.0) 
		_SecondShadowMultColor("Second Shadow Mult Color", Color) = (1, 1, 1, 1.0) 

		_Shininess("Shininess", Float) = 10.0
		_SpecularMultiply("Specular Multiply", Range(-1, 1)) = 0.2

	    _LightSpecularColor("Light Specular Color", Color) = (1.0, 1.0, 1.0 , 1.0)

	    [Toggle(USE_EMISSION)]_UseEmission("Use Emission (Main Texture Alpha)", int) = 0
	    _EmissionIntensity("Emission Intensity", Range(-2.0, 50.0)) = 0.0

	    _EmissionColor("EmissionColor", Color) = (1,1,1,1)
	    _Bias("Bias",float) = 0
	    _TimeOnDuration("ON Duration",float) = 0.5
	    _TimeOffDuration("OFF Duration",float) = 0.5
	    _BlinkingTimeOffsScale("Blinking Time",float) = 5
	    _NoiseAmount("Noise Amount", Range(0,1)) = 0

	    _LightRimColor("Rim Color",Color) = (1.0, 1.0, 1.0, 1.0)
	    _RimPower("Rim Power", Range(0.001, 10.0)) = 0.1
	    _RimMultiply("Rim Multiply", Float) = 0.2
/*
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1.0)
	    _OutlineWidth("Outline Width", Float) = 0.05
		_MaxOutlineZOffset("Max Outline ZOffset", Float) = 0
		_Scale ("Scale", Float) = 0.01
*/
		[Toggle(USE_MatCap)]_UseMatCap("Use MatCap", int) = 0
		//MatCap
		_MatCapColor("MatCap Color", Color) = (1, 1, 1, 1.0)
		_MatCap("MatCap", 2D) = "white" {}
		_MatCapFactor("MatCapFactor", Range(0,5)) = 2
		_MatCapSpecColor("MatCap Specular Color", Color) = (1, 1, 1, 1.0)
		_MatCapSpec ("MatCap Specular", 2D) = "white" {}
		_MatSpecFactor ("MatCap Specular Factor", Range(0,2)) = 0

		[Toggle(USE_Reflection)]_UseReflection("Use Reflection", int) = 0
		//Reflection
		_ReflectionColor("Reflection Color", Color) = (0.2, 0.2, 0.2, 1.0)
		_ReflectionIntensity("Reflection Intensity", Range(1,5)) = 1
		_ReflectionMap("Reflection Cube Map", Cube) = "" {}
		_ReflectionStrength("Reflection Strength", Range(0.0, 1.5)) = 0.5

		_LightDirection("Light Direction", Vector) = (1,1,0)

		_TintColor("Tint Color",Color) = (0.8,0.0,0.0,1.0)
		_TintFactor("Tint Degree",Range(0, 1)) = 0.5

		[KeywordEnum(FinalResult, MainA, LightR, lightG, LightB, VertexRGB, DiffuseArea, LitDiffuse, LitSpecular)]  _DrawMode("Draw Mode", Float) = 0.0

	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry" }
		LOD 100


		Pass
		{
		    Tags { "LightMode" = "ForwardBase"}
			Cull Back
			Lighting Off
			ZWrite On

			CGPROGRAM
			//#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			//#pragma shader_feature _DRAWMODW_RESULT _DRAWMODE_MAINA _DRAWMODE_LIGHTR _DRAWMODE_LIGHTG _DRAWMODE_LIGHTB _DRAWMODE_VERTEXRGB _DRAWMODE_DIFFUSEAREA _DRAWMODE_LITDIFFUSE _DRAWMODE_LITSPECULAR
            #pragma multi_compile _ USE_EMISSION
			#pragma multi_compile _ USE_MatCap
			#pragma multi_compile _ USE_Reflection
			#include "UnityCG.cginc"
			//#include "Lighting.cginc"

			// make fog work
			//#pragma multi_compile_fog
			//#pragma target 2.0					

			struct appdata_t
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR;
				//float2 texcoord1 : TEXCOORD1; 
			};

			struct v2f
			{
			    float4 position : SV_POSITION; 
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPosition : TEXCOORD2;
				//float4 screenPosition : TEXCOORD3;
				float halfLambert : TEXCOORD4;
				float2 texcoord5 : TEXCOORD5;
				float4 MatCap : TEXCOORD6;
				float3 worldSpaceReflectionVector : TEXCOORD3;
				float3 lightDir : TEXCOORD7; 
				//UNITY_FOG_COORDS(1)

				float3	TtoV0 : TEXCOORD8;
				float3	TtoV1 : TEXCOORD9;

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightMapTex;
			float4 _LightMapTex_ST;
			//
            sampler2D _NormalTex;
			float4 _NormalTex_ST;
			float _NormalValue;

			float4 _MainColor;
			float _Intensity;
			float _LightArea;
			float _SecondShadow;

			float4 _FirstShadowMultColor;
			float4 _SecondShadowMultColor;

			float _Shininess;
			float _SpecularMultiply;
			float4 _LightSpecularColor;

			float _EmissionIntensity;

			float4 _LightRimColor;
			float _RimPower;
			float _RimMultiply;

			float4 _EmissionColor;
			float _Bias;
	        float _TimeOnDuration;
	        float _TimeOffDuration;
	        float _BlinkingTimeOffsScale;
	        float _NoiseAmount;

			sampler2D _MatCap;
			float4 _MatCapColor;
			float _MatCapFactor;
			float4 _MatCapSpecColor;
			sampler2D _MatCapSpec;
			float _MatSpecFactor;

			float4 _ReflectionColor;
			float _ReflectionIntensity;
			samplerCUBE _ReflectionMap;
			float _ReflectionStrength;

			half3 _LightDirection;

			float4 _TintColor;
			float _TintFactor;
						
			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o); 

				o.position = UnityObjectToClipPos(v.position);

				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

				//
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);
				TANGENT_SPACE_ROTATION;
				o.TtoV0 = normalize(mul(rotation, UNITY_MATRIX_IT_MV[0].xyz));
				o.TtoV1 = normalize(mul(rotation, UNITY_MATRIX_IT_MV[1].xyz));


				o.color = v.color;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPosition = mul(unity_ObjectToWorld, v.position).xyz;

				//o.screenPosition.xyw = ComputeScreenPos(o.position).xyw;
				//o.screenPosition.z = 1;
				o.lightDir = _LightDirection;
				o.halfLambert = dot(o.worldNormal, o.lightDir) * 0.5 + 0.5;
				//o.halfLambert = dot(o.worldNormal, _WorldSpaceLightPos0.xyz) * 0.5 + 0.5;

#if USE_EMISSION
				//
		       float time = _Time.y + _BlinkingTimeOffsScale;		
		       float fracTime = fmod(time, _TimeOnDuration + _TimeOffDuration);
		       float wave = smoothstep(0,_TimeOnDuration * 0.25, fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75, _TimeOnDuration, fracTime));
		       float noiseTime	= time *  (6.28f / _TimeOnDuration);
		       float noise = sin(noiseTime) * (0.5f * cos(noiseTime * 0.64f + 56.8f) + 0.5f);
		       float noiseWave	= _NoiseAmount * noise + (1 - _NoiseAmount);
			
		       wave = _NoiseAmount < 0.01f ? wave : noiseWave;
		
		       wave += _Bias;

		       o.texcoord5.x = wave;
#endif 

#if USE_MatCap
			   //MatCap
			   o.MatCap.z = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(v.normal));
			   o.MatCap.w = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(v.normal));
			   o.MatCap.zw = o.MatCap.zw * 0.5 + 0.5;
#endif

#if USE_Reflection
			   //Reflection
			   o.worldSpaceReflectionVector  = reflect(o.worldPosition - _WorldSpaceCameraPos.xyz, o.worldNormal);
#endif
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
                float4 mainColor;
                float4 lightMapColor;

                float rgProduct;
                float rgProductFix;

                float3 firstShadowColor; 
                float3 secondShadowClor;

                float3 shadowColor;
                float3 otherColor;
                float3 diffuseColor;

                float3 viewDir;
                float3 halfDir;
                float blinnSpecular;
                float3 specularColor;
                float3 rimColor;

                float3 litColor;
                float3 deltaColor;

				float3 matCapColor;
				float3 matCapSpecColor;
				float3 reflectionColor;
				
				//float3 pointLightColor;
                                                                     
				mainColor = tex2D(_MainTex, i.texcoord.xy);

			    lightMapColor = tex2D(_LightMapTex, i.texcoord.xy);

				//Normal
				float3 normal = UnpackNormal(tex2D(_NormalTex, i.texcoord.zw));
				normal.xy *= _NormalValue;
				normal.z = sqrt(1.0 - saturate( dot(normal.xy ,normal.xy) ) );
				normal = normalize(normal);

				half2 vn;
				vn.x = dot(i.TtoV0, normal);
				vn.y = dot(i.TtoV1, normal);
                vn = vn * 0.5 + 0.5;

				//max(0, dot(tangentNormal, lightDir))
				//float halfLambert1 = max(0, dot(normal, i.lightDir));

				//Diffuse
				rgProduct = i.color.r * lightMapColor.g;

				firstShadowColor = mainColor.rgb * _FirstShadowMultColor;
				secondShadowClor = mainColor.rgb * _SecondShadowMultColor;
/*				
				//PointLight
				pointLightColor = Shade4PointLights(
				                   unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
								   unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
								   unity_4LightAtten0,
								   i.worldPosition, i.worldNormal);
*/

#if _DRAWMODE_DIFFUSEAREA
                shadowColor = ((rgProduct + i.halfLambert) * 0.5 >= _SecondShadow) ? float3(0, 1, 0) : float3(0, 0, 0);

#else
                shadowColor = ((rgProduct + i.halfLambert) * 0.5 >= _SecondShadow) ? firstShadowColor : secondShadowClor;
#endif
                rgProductFix = rgProduct < 0.5 ? rgProduct * 1.25 - 0.125 : rgProduct * 1.2 - 0.1;

#if _DRAWMODE_DIFFUSEAREA
                otherColor = ((rgProductFix + i.halfLambert) * 0.5 >= _LightArea) ? float3(1, 1, 1) : float3(1, 0, 0);
#else 
                otherColor = ((rgProductFix + i.halfLambert) * 0.5 >= _LightArea) ? mainColor.rgb : firstShadowColor;
#endif
                diffuseColor = rgProduct >= 0.09 ? otherColor : shadowColor;
                //diffuseColor = rgProduct >= 0.09 ? (otherColor + pointLightColor) : shadowColor;

                //Specular
                viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition.xyz);
                //halfDir = normalize(viewDir + _WorldSpaceLightPos0.xyz);
				halfDir = normalize(viewDir + i.lightDir);
                blinnSpecular = pow(max(dot(normalize(i.worldNormal), halfDir), 0), _Shininess);
                specularColor = (lightMapColor.b + blinnSpecular <= 1.0) ? float3(0, 0, 0) : _LightSpecularColor.xyz * _SpecularMultiply * lightMapColor.r;

              //Normalize View  
              //float3 worldViewDir = normalize(i.worldViewDir);   
             // float rim = 1 - max(0, dot(worldViewDir, worldNormal));  
                float rim = pow((1 - max(dot(viewDir, i.worldNormal), 0)), 1 / _RimPower); 
              //RimLight  
             // fixed3 rimColor = _RimColor * pow(rim, 1 / _RimPower); 
              
                rimColor = (rim <= 0.5) ? float3(0, 0, 0) : _LightRimColor.xyz * _RimMultiply * lightMapColor.r;

//      float		time 			= _Time.y + _BlinkingTimeOffsScale;		
//		float		fracTime	= fmod(time,_TimeOnDuration + _TimeOffDuration);
//		float		wave			= smoothstep(0,_TimeOnDuration * 0.25,fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75,_TimeOnDuration,fracTime));
//		float		noiseTime	= time *  (6.2831853f / _TimeOnDuration);
//		float		noise			= sin(noiseTime) * (0.5f * cos(noiseTime * 0.6366f + 56.7272f) + 0.5f);
//		float		noiseWave	= _NoiseAmount * noise + (1 - _NoiseAmount);
//			
//		wave = _NoiseAmount < 0.01f ? wave : noiseWave;
//		
//		wave += _Bias;

                //Combine
                litColor = (diffuseColor  + specularColor + rimColor ) * _MainColor.xyz * _Intensity;

                //deltaColor.xyz = mainColor.xyz * _EmissionIntensity - litColor;
                deltaColor.xyz = mainColor.xyz * _EmissionIntensity;
#if USE_MatCap
				//MatCap
				//matCapColor = tex2D(_MatCap, i.texcoord.zw).rgb;
				//matCapColor = tex2D(_MatCap, i.MatCap.zw).rgb * _MatCapColor * _MatCapFactor;
				//matCapSpecColor = tex2D(_MatCapSpec, i.MatCap.zw) * _MatCapSpecColor * _MatSpecFactor;
				matCapColor = tex2D(_MatCap, vn).rgb * _MatCapColor * _MatCapFactor;
				matCapSpecColor = tex2D(_MatCapSpec, vn) * _MatCapSpecColor * _MatSpecFactor;
#endif

#if USE_Reflection
				//Reflection
				reflectionColor = texCUBE(_ReflectionMap, i.worldSpaceReflectionVector).rgb * _ReflectionColor.rgb *  _ReflectionIntensity;
#endif

                fixed4 finalColor;
				
                #if USE_EMISSION
                //finalColor = fixed4((mainColor.a * deltaColor * i.texcoord5.x * _EmissionColor  + litColor), finalColor.a);
				
				#if USE_Reflection
				finalColor  = fixed4((mainColor.a * deltaColor * i.texcoord5.x * _EmissionColor  + litColor), finalColor.a);
				fixed4 RefColor = fixed4(lerp(finalColor.rgb, reflectionColor , _ReflectionStrength), finalColor.a);
				finalColor = fixed4(lerp(finalColor.rgb, RefColor.rgb, lightMapColor.a), finalColor.a);
				#else
				finalColor = fixed4((mainColor.a * deltaColor * i.texcoord5.x * _EmissionColor  + litColor), finalColor.a);
				#endif

				#if USE_MatCap
				//finalColor = fixed4(finalColor.rgb * matCapColor , finalColor.a);
				finalColor = fixed4(lerp(finalColor.rgb, matCapColor * finalColor.rgb + matCapSpecColor , lightMapColor.a), finalColor.a);
				#else
				finalColor = fixed4(finalColor.rgb, finalColor.a);
				#endif

				
                #else
				//finalColor = fixed4( litColor, finalColor.a); 

				#if USE_Reflection
				finalColor = fixed4( litColor, finalColor.a);
				fixed4 RefColor = fixed4( lerp(litColor,  reflectionColor , _ReflectionStrength ), finalColor.a); 
				finalColor = fixed4(lerp(litColor.rgb, RefColor.rgb, lightMapColor.a), finalColor.a);
				#else
				finalColor = fixed4( litColor, finalColor.a); 
				#endif

				#if USE_MatCap
                //finalColor = fixed4( finalColor.rgb * matCapColor , finalColor.a); 
				finalColor = fixed4(lerp(finalColor.rgb, matCapColor * finalColor.rgb + matCapSpecColor , lightMapColor.a), finalColor.a);
				#else 
				finalColor = fixed4( finalColor.rgb, finalColor.a); 
				#endif

				
                #endif



				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);

				fixed4 col;
				col.rgb = lerp(finalColor.rgb, _TintColor, _TintFactor);
				col.a = 1;
				return col;
			}
			ENDCG
		}
	}
}