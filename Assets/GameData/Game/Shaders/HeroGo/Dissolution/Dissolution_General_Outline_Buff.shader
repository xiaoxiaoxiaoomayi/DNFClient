Shader "HeroGo/Dissolution/Outline_Buff" {
    Properties {
        _MainColor ("Main Color", Color) = (0.5,0.5,0.5,1)
        _MainTextuer ("Main Textuer", 2D) = "white" {}
		_DiffuseIntensity ("Diffuse Intensity", Range(-0.5, 0.5)) = 0
		//[Space(20)]
		[Header(______________________________________________)]
        _SpecColor ("Spec Color", Color) = (0.5,0.5,0.5,1)
        _SpeTextuer ("Spec Textuer", 2D) = "white" {}
		_SpeIntensity ("Spec Intensity", Range(0, 1)) = 0.5

		[Header(______________________________________________)]
		_NoiseTex ("Noise Textuer", 2D) = "white" {}
		_debrisSpeed ("Debris Speed", Range(0, 2)) = 1
		_debrisSize ("Debris Size", Range(0, 2)) = 1
		_windSpeed ("Wind Speed", Range(0, 2)) = 1
		_windPower ("Wind Power", Range(0, 1)) = 0.5
		_windFrequency ("Wind Frequency", Range(0, 1)) = 0.5
		//[Space(20)]
		[Header(______________________________________________)]
        [Toggle(USE_RIM)] _rimLight ("Rim", Float ) = 0
        _RimColor ("Rim Color", Color) = (0.5,0.5,0.5,1)
        _RimExp ("Rim Exp", Range(5, 1)) = 4
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 0.5
		//[Space(20)]
		[Header(______________________________________________)]
        [Toggle(UES_TWINK)] _Twinkle ("Twinkle", Float ) = 0
        _TwinkleColor ("Twinkle Color", Color) = (0.35,0.35,0.35,1)
        _TwinkleSpeed ("Twinkle Speed", Range(0, 10)) = 2.5
		//[Space(20)]
		[Header(______________________________________________)]
        _Normal ("Normal", 2D) = "bump" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		//[Space(20)]
		[Header(______________________________________________)]
		//Outline
		_OutlineColor ("Outline Color", Color) = (1, 0, 0, 1)
	    _OutlineWidth("Outline Width", Float) = 0.05
		_MaxOutlineZOffset("Max Outline ZOffset", Float) = 0
		_Scale ("Scale", Float) = 0.01
		[HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }

    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
		LOD 100

		Pass
		{
		Cull Front
	
		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag

		struct appdata_t
		{
            float4 position : POSITION;
            float3 normal : NORMAL;
            float4 color : COLOR;
			float2 texcoord0 : TEXCOORD0;
		};

		struct v2f
		{
		   float4 position : SV_POSITION;
		   float4 color : COLOR0;
		   float2 uv0 : TEXCOORD0;
		};

		sampler2D _SpeTextuer;
		float _OutlineWidth;
		float4 _OutlineColor;
		float _MaxOutlineZOffset;
		float _Scale;
		float _Cut;

		sampler2D _NoiseTex;
		float _debrisSpeed;
		fixed _debrisSize;
		float _windSpeed;
		float _windPower;
		float _windFrequency;

		v2f vert (appdata_t v)
		{
		   v2f o;
		  // UNITY_INITIALIZE_OUTPUT(v2f, o); 

		   float3 viewNormal;
		   float2 unitNormal;
		   float3 viewPosition;
		   float4 tempPosition;
		   float xyScale;

		   o.color = v.color;
		   o.uv0 = v.texcoord0;
		   fixed VerColGOneMinus = (1.0 - o.color.g);

		   float sineWave = sin(_Time.a * _windSpeed + (VerColGOneMinus * (_windFrequency * 120.0)));
           v.position.xyz += float3(0.8,0.4,1) * sineWave * o.color.g * _windPower * 0.06 + 0.03;
		   viewNormal.xy =  float2(mul((float3x3)UNITY_MATRIX_MV, v.normal.xyz).xy);
		   viewNormal.z = 0.009;
		   unitNormal = normalize(viewNormal).xy;
		   viewPosition = mul(UNITY_MATRIX_MV, v.position);

		   tempPosition.xyz = normalize(viewPosition).xyz;
		   tempPosition.xyz = tempPosition.xyz * _MaxOutlineZOffset;
		   tempPosition.xyz = tempPosition.xyz * _Scale;
		   tempPosition.xyz = tempPosition.xyz  + viewPosition.xyz;

		   xyScale = _OutlineWidth * _Scale * sqrt(-viewPosition.z / unity_CameraProjection[1].y / _Scale); 
		   viewPosition.xy = unitNormal * xyScale + tempPosition.xy;
		   o.position = mul(UNITY_MATRIX_P, float4(viewPosition.x, viewPosition.y, tempPosition.z, 1.0));
		   return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed2 MoveBTexV = ((i.uv0 * 5.0 - 1.0)+_Time.g * float2(0,0.6));
            fixed4 NoiseB = tex2D(_NoiseTex , MoveBTexV);
            fixed2 MoveATexV = ((float2((2.0 * i.uv0.r),i.uv0.g) * 1.8 - 0.3) + _Time.g * float2(0,0.13));
            fixed4 NoiseA = tex2D(_NoiseTex , MoveATexV);
            fixed VerColROneMinus = (1.0 - i.color.r);
            fixed NoiseAll = ((NoiseB.b * NoiseA.b) + saturate(VerColROneMinus * 0.5)) * saturate(VerColROneMinus * 2.0);
            clip((NoiseAll) - 0.5);
            return fixed4(_OutlineColor.rgb,0);
		}

		ENDCG
	}

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
				
            }
            //Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#pragma multi_compile USE_RIM
			#pragma multi_compile UES_TWINK
            #pragma target 2.0

            sampler2D _MainTextuer; 
            fixed4 _MainColor;
			fixed _DiffuseIntensity;
            fixed4 _SpecColor;
			fixed _SpeIntensity;
            sampler2D _Normal;
            sampler2D _SpeTextuer;
            fixed _RimExp;
            fixed _TwinkleSpeed;
            fixed4 _TwinkleColor;
            fixed4 _RimColor;
            fixed _rimLight;
            fixed _Twinkle;
            fixed _RimIntensity;
			sampler2D _NoiseTex;
			float _debrisSpeed;
			fixed _debrisSize;
			float _windSpeed;
			float _windPower;
			float _windFrequency;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
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
				float3 halfDirection : TEXCOORD7;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                fixed VerColGOneMinus = (1.0 - o.vertexColor.g);
				fixed sineWave = sin(_Time.a+(VerColGOneMinus*80.0));
                v.vertex.xyz += fixed3(0.8,0.4,1)*sineWave*o.vertexColor.g*0.03;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
				o.viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
				o.lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				o.halfDirection = normalize(o.viewDirection + o.lightDirection);
                return o;
            }

            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float faceSign = facing >= 0 ? 1 : -1 ;
                i.normalDir *= faceSign;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                fixed3 _Normal_var = UnpackNormal(tex2D(_Normal,i.uv0));
                float3 normalLocal = _Normal_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals

				float TimeScale = _Time.g * _debrisSpeed;

                float2 MoveBTexV = (i.uv0  *5.0 - 1.0) + TimeScale * float2(0,0.6);

				fixed NoiseB = tex2D(_NoiseTex,MoveBTexV).r;

                float2 MoveATexV = (float2((2.0 * i.uv0.r) , i.uv0.g) * 1.8 - 0.3) + TimeScale * float2(0,0.13);

				fixed NoiseA = tex2D(_NoiseTex,MoveATexV).r;

                fixed VerColROneMinus = 1.0 - i.vertexColor.r;
                fixed NoiseAll = (NoiseB * NoiseA + (VerColROneMinus * 0.5)) * saturate(VerColROneMinus * 2.0);//
                clip(NoiseAll - 0.5);
////// Emissive:
                fixed4 _MainTextuer_var = tex2D(_MainTextuer,i.uv0);
				fixed3 mainColor  = _MainColor.rgb + _DiffuseIntensity;
                fixed3 DiffMulCol = (_MainTextuer_var.rgb * mainColor); // Diffuse Color
                fixed Lambert = max(0,dot(i.lightDirection,abs(normalDirection))); // Lambert
                fixed4 speA = tex2D(_SpeTextuer,i.uv0);

				fixed3 specularExp = lerp(1,7,lerp((_SpeIntensity * speA.r),_SpeIntensity + speA.r,_SpeIntensity));
				specularExp *= 4;
				fixed speculerPow = pow(max(0,dot(abs(normalDirection),i.halfDirection)),specularExp);
				fixed3 specColor = (_SpecColor+ _SpecColor) * _SpeIntensity;
				fixed3 lambertSpec = (DiffMulCol*Lambert)+Lambert*speculerPow*(specColor * speA.g);

			#if USE_RIM
				fixed3 rimColor = (_RimColor.rgb * 2.0);
				fixed rimExpPow = pow(1.0-max(0,dot(normalDirection, i.viewDirection)),_RimExp);
				fixed rimIntensity = ((rimExpPow * saturate((1 - i.vertexColor.g) * 2 - 1.2)) + (step(NoiseAll,0.55) * i.vertexColor.r)) * _RimIntensity;
				fixed3 rimLightLerp = lerp( 0, rimIntensity, _rimLight );
				fixed3 basicResult = lerp(lambertSpec,rimColor,rimLightLerp);
			#else
				fixed3 basicResult = lambertSpec;
			#endif

			#if UES_TWINK
				fixed4 twinkleLerp = lerp( 0, (speA.b*(sin((_Time.g*_TwinkleSpeed))*0.5+0.5)), _Twinkle );
				fixed3 twinkleColor = (_MainTextuer_var.rgb*0.95+0.05)*_TwinkleColor.rgb;
				float3 finalColor = DiffMulCol + lerp(basicResult,twinkleColor,twinkleLerp);
			#else
				float3 finalColor = DiffMulCol + basicResult;
			#endif

				return fixed4(finalColor,1);
            }

            ENDCG
        }


    }

    FallBack "HeroGo/Dissolution/General"
}
