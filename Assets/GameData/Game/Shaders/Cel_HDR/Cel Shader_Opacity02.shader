Shader "Cel Shadader/Gun"
{
	Properties
	{	    
		_MainTex ("Main Texture", 2D) = "white" {}
		_LightMapTex("Light Map",2D) = "white"{}

		_MainColor("Main Color", Color) = (0.9313725, 0.9313725, 0.9313725, 1.0)
		_Intensity("Intensity", Range(0, 2)) = 1
		_LightArea("Light Area", Float) = 0.51
		_SecondShadow("Second Shadow", Float) = 0.51

		_FirstShadowMultColor("First Shadow Mult Clor", Color) = (0.9215686, 0.7686275, 0.8, 1.0) 
		_SecondShadowMultColor("Second Shadow Mult Color", Color) = (0.8313726, 0.6, 0.5882353, 1.0) 

		_Shininess("Shininess", Float) = 10.0
		_SpecularMultiply("Specular Multiply", Float) = 0.2

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
	    _RimPower("Rim Power", Range(0.001, 50.0)) = 0.1
	    _RimMultiply("Rim Multiply", Float) = 0.2

//	    _OutlineColor ("Outline Color", Color) = (0.4117647, 0.3112941, 0.3768184, 1)
//	    _OutlineWidth("Outline Width", Float) = 0.05
//		_MaxOutlineZOffset("Max Outline ZOffset", Float) = 0
//		_Scale ("Scale", Float) = 0.01
		_Opacity("Opacity", Range(0, 1)) =1

//	 _RefBaseIntensity("Ref Base Intensity", Range(-0.2 , 1)) = 0.1
//	 _RefGlowIntensity("Ref Glow Intensity", Range(0, 3)) = 1.5
//	 _RefBlurOffset("Ref Blur Offset",Range(0, 0.1)) = 0

		[KeywordEnum(FinalResult, MainA, LightR, lightG, LightB, VertexRGB, DiffuseArea, LitDiffuse, LitSpecular)]  _DrawMode("Draw Mode", Float) = 0.0

	}

	SubShader
	{
	    Tags { "RenderType"="Transparent" "Queue"="Transparent"  "Reflection" = "RenderReflectionOpaque" }
		//Tags { "RenderType"="Opaque"  }

		LOD 100


		/*
		Pass
		{
		Tags { "Queue" = "Geometry+66"  "LightMode" = "Always"}          //Tags { "RenderType"="Opaque" "Queue" = "Geometry+66" }
		//LOD  200
		Cull Front
	
		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag

		// Use shader model 3.0 target, to get nicer looking lighting
		//#pragma target 3.0

		//#pragma multi_compile _DRAWMODE_RESULT _DRAWMODE_OUTDIRXY _DRAWMODE_OUTDIRX _DRAWMODE_OUTDIRY 

		struct appdata_t
		{

            float4 position : POSITION;
            float3 normal : NORMAL;
            float4 color : COLOR;

		};

		struct v2f
		{
		   float4 position : SV_POSITION;
		   float4 color : COLOR0;
		   float4 screenPositon : TEXCOORD3;

		};


		float _OutlineWidth;
		float4 _OutlineColor;
		float _MaxOutlineZOffset;
		float _Scale;


		v2f vert (appdata_t v)
		{
		   v2f o;
		   UNITY_INITIALIZE_OUTPUT(v2f, o); 

		   float3 viewNormal;
		   float2 unitNormal;

		   float3 viewPosition;
		   float4 tempPosition;

		   float xyScale;

		   viewNormal.xy =  mul(UNITY_MATRIX_MV, v.normal.xyz).xy;
		   viewNormal.z = 0.009;

		   unitNormal = normalize(viewNormal).xy;

		   viewPosition = mul(UNITY_MATRIX_MV, v.position);

		   tempPosition.xyz = normalize(viewPosition).xyz;
		   tempPosition.xyz = tempPosition.xyz * _MaxOutlineZOffset;
		   tempPosition.xyz = tempPosition.xyz * _Scale;
		   tempPosition.xyz = tempPosition.xyz * (v.color.b - 0.5) + viewPosition.xyz;


		   xyScale = _OutlineWidth * _Scale * v.color.a * sqrt(-viewPosition.z / unity_CameraProjection[1].y / _Scale); 
		   viewPosition.xy = unitNormal * xyScale + tempPosition.xy;


		   o.position = mul(UNITY_MATRIX_P, float4(viewPosition.x, viewPosition.y, tempPosition.z, 1.0));

/*
#if _DRAWMODE_RESULT
				o.color.rgb = _OutlineColor.rgb;
#else
				o.color.rg = (unitNormal.xy + 1.0) / 2;
				o.color.b = 0.0;
#endif
				o.color.a = 1.0;
*/
          o.color.rgb = _OutlineColor.rgb; 
		   return o;

		}


		fixed4 frag (v2f i) : SV_Target
		{

/*
#if _DRAWMODE_RESULT
				return i.color;
#endif
#if _DRAWMODE_OUTDIRXY
				float4 dirXY;
				dirXY.x = i.color.x < 0.5 ? 1.0 : 0.0;
				dirXY.y = i.color.y < 0.5 ? 1.0 : 0.0;
				dirXY.z = 0.0;
				dirXY.w = 1.0;
				return dirXY;
#endif
#if _DRAWMODE_OUTDIRX
				return i.color.x < 0.5 ? float4(1, 0, 0, 1) : float4(0, 1, 0, 1);
#endif
#if _DRAWMODE_OUTDIRY
				return i.color.y < 0.5 ? float4(1, 0, 0, 1) : float4(0, 1, 0, 1);
#endif
*/       
                return i.color;

		}


		ENDCG
	}
	*/


		Pass
		{
		    Tags { "LightMode" = "ForwardBase"   }
		     //Tags {"Queue" = "Transparent"  "LightMode" = "ForwardBase"}
		   LOD 100
		   ZWrite Off
		   //Cull Off  //
		   //Blend One One
		   Blend One OneMinusSrcAlpha
		    //Blend SrcAlpha OneMinusSrcAlpha, Zero Zero  
            //BlendOp Add, Add 


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _DRAWMODW_RESULT _DRAWMODE_MAINA _DRAWMODE_LIGHTR _DRAWMODE_LIGHTG _DRAWMODE_LIGHTB _DRAWMODE_VERTEXRGB _DRAWMODE_DIFFUSEAREA _DRAWMODE_LITDIFFUSE _DRAWMODE_LITSPECULAR
            #pragma shader_feature USE_EMISSION
			// make fog work
			//#pragma multi_compile_fog
			//#pragma target 2.0
			
			#include "UnityCG.cginc"


			struct appdata_t
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR;
				//float2 texcoord1 : TEXCOORD1; 
			};

			struct v2f
			{
			    float4 position : SV_POSITION; 
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPosition : TEXCOORD2;
				float4 screenPosition : TEXCOORD3;
				float halfLambert : TEXCOORD4;
				float2 texcoord5 : TEXCOORD5;
				//UNITY_FOG_COORDS(1)

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightMapTex;
			float4 _LightMapTex_ST;

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

	        float _Opacity;

//	     fixed  _RefBaseIntensity;
//		 fixed _RefGlowIntensity;
//
//		 fixed _RefBlurOffset;

						
			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o); 
				o.position = UnityObjectToClipPos(v.position);

				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.color = v.color;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPosition = mul(unity_ObjectToWorld, v.position).xyz;

				o.screenPosition.xyw = ComputeScreenPos(o.position).xyw;
				//o.screenPosition.z = 1;
				o.halfLambert = dot(o.worldNormal, _WorldSpaceLightPos0.xyz) * 0.5 + 0.5;


				//
		       float time = _Time.y + _BlinkingTimeOffsScale;		
		       float fracTime = fmod(time, _TimeOnDuration + _TimeOffDuration);
		       float wave = smoothstep(0,_TimeOnDuration * 0.25, fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75, _TimeOnDuration, fracTime));
		       float noiseTime	= time *  (6.2831853f / _TimeOnDuration);
		       float noise = sin(noiseTime) * (0.5f * cos(noiseTime * 0.6366f + 56.7272f) + 0.5f);
		       float noiseWave	= _NoiseAmount * noise + (1 - _NoiseAmount);
			
		       wave = _NoiseAmount < 0.01f ? wave : noiseWave;
		
		       wave += _Bias;

		       o.texcoord5.x = wave;


				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}


			fixed4 frag (v2f i) : SV_Target
			{

                float4 mainColor;
                float3 lightMapColor;

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
                                                    
                 
				mainColor = tex2D(_MainTex, i.texcoord.xy);


			    lightMapColor = tex2D(_LightMapTex, i.texcoord.xy);

				//漫反射
				rgProduct = i.color.r * lightMapColor.g;

				firstShadowColor = mainColor.rgb * _FirstShadowMultColor;
				secondShadowClor = mainColor.rgb * _SecondShadowMultColor;

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

                //高光反射
                viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition.xyz);
                halfDir = normalize(viewDir + _WorldSpaceLightPos0.xyz);
                blinnSpecular = pow(max(dot(normalize(i.worldNormal), halfDir), 0), _Shininess);
                specularColor = (lightMapColor.b + blinnSpecular <= 1.0) ? float3(0, 0, 0) : _LightSpecularColor.xyz * _SpecularMultiply * lightMapColor.r;


                 //计算RimLight  
                //把视线方向归一化  
                //float3 worldViewDir = normalize(i.worldViewDir);  
                //计算视线方向与法线方向的夹角，夹角越大，dot值越接近0，说明视线方向越偏离该点，也就是平视，该点越接近边缘  
               // float rim = 1 - max(0, dot(worldViewDir, worldNormal));  
                  float rim = pow((1 - max(dot(viewDir, i.worldNormal), 0)), 1 / _RimPower); 
                //计算rimLight  
               // fixed3 rimColor = _RimColor * pow(rim, 1 / _RimPower); 
              
                rimColor = (rim <= 0.5) ? float3(0, 0, 0) : _LightRimColor.xyz * _RimMultiply * lightMapColor.r;


//      float		time 			= _Time.y + _BlinkingTimeOffsScale ;		
//		float		fracTime	= fmod(time,_TimeOnDuration + _TimeOffDuration);
//		float		wave			= smoothstep(0,_TimeOnDuration * 0.25,fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75,_TimeOnDuration,fracTime));
//		float		noiseTime	= time *  (6.2831853f / _TimeOnDuration);
//		float		noise			= sin(noiseTime) * (0.5f * cos(noiseTime * 0.6366f + 56.7272f) + 0.5f);
//		float		noiseWave	= _NoiseAmount * noise + (1 - _NoiseAmount);
//			
//		wave = _NoiseAmount < 0.01f ? wave : noiseWave;
//		
//		wave += _Bias;


                //combine
                litColor = (diffuseColor + specularColor + rimColor) * _MainColor.xyz * _Intensity;

                //deltaColor.xyz = mainColor.xyz * _EmissionIntensity - litColor;
                deltaColor.xyz = mainColor.xyz * _EmissionIntensity ;

                fixed4 finalColor;

                #if USE_EMISSION
                finalColor = fixed4((mainColor.a * deltaColor * i.texcoord5.x * _EmissionColor  + litColor), _Opacity);
                #else
                finalColor = fixed4( litColor , _Opacity); 
                #endif


#if _DRAWMODE_RESULT
                return finalColor;
#endif

#if _DRAWMODE_MAINA
                return mainColor.a;
#endif

#if _DRAWMODE_LIGHTR
                return lightMapColor.r;
#endif

#if _DRAWMODE_LIGHTG
                return lightMapColor.g;
#endif

#if _DRAWMODE_LIGHTB
                return lightMapColor.b;
#endif

#if _DRAWMODE_VERTEXRGB
                return i.color;
#endif

#if _DRAWMODE_DIFFUSEAREA
                return fixed4(diffuseColor, 1);
#endif

#if _DRAWMODE_LITDIFFUSE
                return fixed4(diffuseColor, 1);
#endif

#if _DRAWMODE_LITSPECULAR
                return fixed4(specularColor, 1);
#endif

				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return finalColor;
			}
			ENDCG
		}

	}

}
