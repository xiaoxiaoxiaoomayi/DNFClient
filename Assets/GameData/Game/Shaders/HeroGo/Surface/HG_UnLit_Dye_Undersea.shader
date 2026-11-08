// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeroGo/General/UnLit/HG_Unlit_Dye_Undersea"
{
	Properties
	{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_DyeColor("Dye color",Color) = (1.0,1.0,1.0,1.0)
		_ColorStrength("Color Strength",Range(0, 1)) = 0.3
		[Header(______________________________________________)]
		[Toggle(UES_CAUSTICS)] _uesCaustics ("Ues Caustics", Float ) = 1
        [Toggle(UES_SPACE_MAP)] _uesSpaceMap ("UES Space Map", Float ) = 1
        _SpaceMap ("Space Map", 2D) = "black" {}

        _CausticsTexture ("Caustics Texture", 2D) = "black" {}
        _causticsColor ("Caustics Color", Color) = (0.5,1,1,1)
        [Toggle(REVERSAL)] _ReversalEffect ("Caustics Reversal", Float ) = 0
        _CausticsScale ("Caustics Scale", Range(0.1, 3)) = 1
        _CausticsIntensity ("Caustics Intensity", Range(0, 1)) = 1
        _CausticsSpeed ("Caustics Speed", Range(-1, 1)) = 0.3
		_NoiseTexture ("Noise Texture", 2D) = "white" {}

		[Toggle(UESREF)] _uesRefractio ("Ues Refraction", Float ) = 1
        _refInten ("Refraction Intensity", Range(0, 1)) = 0.25
        _refSpeed ("Refraction Speed", Range(0, 1)) = 0.5
        _refFrequ ("Refraction Frequency", Range(1, 20)) = 10
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#pragma multi_compile _ UES_CAUSTICS
			#pragma multi_compile _ UES_SPACE_MAP
			#pragma multi_compile _ REVERSAL
			#pragma multi_compile _ UESREF
			
			#include "UnityCG.cginc"
			#include "../../Includes/TMShaderSupport.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _DyeColor;
			half _ColorStrength;

			sampler2D _MainTexture; float4 _MainTexture_ST;
            sampler2D _SpaceMap;
            sampler2D _CausticsTexture; float4 _CausticsTexture_ST;
            sampler2D _NoiseTexture;  float4 _NoiseTexture_ST;
            fixed _CausticsSpeed;
            fixed _CausticsIntensity;
            fixed _refInten;
            fixed _refFrequ;
            fixed _refSpeed;
            fixed _CausticsScale;
            fixed4 _causticsColor;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				

				#ifdef UESREF
				float moveValue = (i.texcoord.g - (_Time.g * _refSpeed)) * _refFrequ;
				float2 basicsUv = float2((i.texcoord.r + (sin(moveValue) * (_refInten * 0.01) * i.texcoord.g)), i.texcoord.g);//wave***
			#else
				float2 basicsUv = i.texcoord;
			#endif


			#ifdef UES_CAUSTICS
				#ifdef UES_SPACE_MAP
					float4 spaceTex = tex2D(_SpaceMap, basicsUv);
					float4 SpaceAll = spaceTex;
				#else
					float4 defaultData = float4(i.texcoord.r, i.texcoord.g, 0.5, 1);
					float4 SpaceAll = defaultData;
				#endif

				#ifdef REVERSAL
					float remapSpeed = _CausticsSpeed * 0.3;
					float reversalEffect = remapSpeed * -1.0;
				#else
					float remapSpeed = _CausticsSpeed * 0.3;
					float reversalEffect = remapSpeed;
				#endif

                
				float2 spaceScale = (1 - _CausticsScale) * float2(0.5, 0.5) + SpaceAll.rg * _CausticsScale;//fixed2 spaceScale = lerp(fixed2(0.5, 0.5), SpaceAll.rg, _CausticsScale);

                float2 mainUv = float2(((_Time.g * reversalEffect) + spaceScale.r), spaceScale.g);//mainUv

                float2 disUv = float2((spaceScale.r + (_Time.g * -reversalEffect)), spaceScale.g);//disUv

                float2 noiseTex = tex2D(_NoiseTexture, TRANSFORM_TEX(disUv, _NoiseTexture)).rg;
                float disturbance = noiseTex.r * 0.1;
                float2 cauUv = mainUv + disturbance;   //cauUv

                fixed4 causticsTex = tex2D(_CausticsTexture, TRANSFORM_TEX(cauUv, _CausticsTexture));
                fixed topDirecMask = SpaceAll.a + 0.2;
				fixed naturalMask = saturate(noiseTex.g + 0.2);

				fixed2 maskRG = i.texcoord * 2.0 - 1.0;
				maskRG = abs(maskRG);
                fixed edgeMask = saturate((max(maskRG.r, maskRG.g) * -20.0 + 20.0));//edgeMask

                fixed3 effc = naturalMask * edgeMask * causticsTex.r * topDirecMask * SpaceAll.b * _CausticsIntensity * _causticsColor.rgb * _causticsColor.a; //SpaceAll.b == depthMask
                fixed4 mainTex = tex2D(_MainTex,basicsUv) * _DyeColor;

				mainTex.rgb = lerp(mainTex.rgb, mainTex.rgb * SafeNormalize(mainTex.rgb), _ColorStrength);
				UNITY_APPLY_FOG(i.fogCoord, mainTex);

                fixed3 finalColor = effc + mainTex.rgb;
				fixed4 finalRGBA = fixed4(finalColor,mainTex.a);
			#else
				fixed4 mainTex = tex2D(_MainTex,basicsUv);
				fixed4 finalRGBA = mainTex;
			#endif
				
                return finalRGBA;
			}
			ENDCG
		}
	}

}
