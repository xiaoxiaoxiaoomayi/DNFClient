// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// - Unlit
// - Per-vertex (virtual) camera space specular light
// - SUPPORTS lightmap
Shader "HeroGo/General/UnLit/Wind" {
Properties {
	_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}

	_DyeColor("Color", Color) = (1,1,1,1)
	//
	_Brightness("Intensity", Float) = 1
	_Saturation("Saturation", Float) = 1
	_Contrast("Contrast", Float) = 1

	_Wind("Wind params",Vector) = (1,1,1,1)
	_speed("Windspeed",Vector) = (0,0,0,0)
	_WindEdgeFlutter("Wind edge fultter factor", float) = 0.5
	_WindEdgeFlutterFreqScale("Wind edge fultter freq scale",float) = 0.5
}

SubShader {
	Tags {"Queue"="Transparent" "RenderType"="Transparent" "LightMode"="ForwardBase"}
	LOD 100
	
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off 
	ZWrite Off
	
	
	CGINCLUDE
	#include "UnityCG.cginc"
	//TerrainEngine.cginc里面有一个AnimateVertex2函数
	#include "TerrainEngine.cginc"
	sampler2D _MainTex;
	float4 _MainTex_ST;

	fixed4 _DyeColor;
	//
	half _Brightness;
	half _Saturation;
	half _Contrast;
	
	//#ifndef LIGHTMAP_OFF
	// float4 unity_LightmapST;
	// sampler2D unity_Lightmap;
	//#endif
	
	float _WindEdgeFlutter;
	float _WindEdgeFlutterFreqScale;
	float4	_speed;

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
//		#ifndef LIGHTMAP_OFF
//		float2 lmap : TEXCOORD1;
//		#endif
		fixed3 spec : TEXCOORD2;
		float4 worldpos :TEXCOORD3;
		UNITY_FOG_COORDS(1)
	};

inline float4 AnimateVertex2(float4 pos,float4 worldpos, float3 normal, float4 animParams,float4 wind,float2 time)
{	
	// animParams stored in color
	// animParams.x = branch phase
	// animParams.y = edge flutter factor
	// animParams.z = primary factor
	// animParams.w = secondary factor

	float fDetailAmp = 0.1f;
	float fBranchAmp = 0.3f;
	
	// Phases (object, vertex, branch)
	float fObjPhase = dot(worldpos.xyz, 1);
	float fBranchPhase = fObjPhase + animParams.x;
	
	float fVtxPhase = dot(pos.xyz, animParams.y + fBranchPhase);
	
	// x is used for edges; y is used for branches
	//旗子本身的摆动用了y,也就是植物的茎,旗子边上的摆动用了x,也就是叶子的边
	float2 vWavesIn = time  + float2(fVtxPhase, fBranchPhase );
	
	// 1.975, 0.793, 0.375, 0.193 are good frequencies
	//将两个频率映射成四个
	float4 vWaves = (frac( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0);

	//使用了三角波,就是为了不用sin,cos为了一点效率
	vWaves = SmoothTriangleWave( vWaves );

	//在做一些游戏效果的时候经常需要用到正弦波,它平滑又有周期性,但是sin的计算开销略大.作为优化,在GPU Gem上看到一个用三次函数平滑三角波得到近似正弦波的方法不错
	/*
	float4 SmoothCurve( float4 x ) {
     return x * x *( 3.0 - 2.0 * x );
    }
    float4 TriangleWave( float4 x ) {
     return abs( frac( x + 0.5 ) * 2.0 - 1.0 );
    }
    float4 SmoothTriangleWave( float4 x ) {
     return SmoothCurve( TriangleWave( x ) );
   }
   */			
   //将两个频率合并，为了看上去没有规律
	float2 vWavesSum = vWaves.xz + vWaves.yw;

	// Edge (xz) and branch bending (y)
	//融合的部分,animParams.y叶子的权重从顶点色的绿色获得,fDetailAmp振幅, normal法线叶子是按法线方向飘动的
	float3 bend = animParams.y * fDetailAmp * normal.xyz;
	bend.y = animParams.w * fBranchAmp;
		pos.xyz += ((vWavesSum.xyx * bend) + (wind.xyz * vWavesSum.y * animParams.w)) * wind.w; 

	

	pos.xyz =pos.xyz+ animParams.z * wind.xyz;
	//pos.x = sin(pos.x+_Time.x *3.14) * animParams.w;
	
	return pos;
}
	
	v2f vert (appdata_full v)
	{
		v2f o;
		
		float4	wind;
		
		float			bendingFact	= v.color.a;
		o.worldpos = mul(unity_ObjectToWorld,v.vertex);
		float4 worldpos1 =o.worldpos;
		_Wind.x = sin((_Time.x * 30 + worldpos1.x) *_speed.x) * 0.06 * _speed.x;   //调节WindX方向
		_Wind.y = sin((_Time.x * 30 + worldpos1.y) *_speed.y) * 0.06 * _speed.y;   //调节WindY方向

		wind.xyz	= mul((float3x3)unity_WorldToObject,_Wind.xyz);
		wind.w		= _Wind.w  * bendingFact;
		
		
		float4	windParams	= float4(0,_WindEdgeFlutter,bendingFact.xx);
		
		
		float 		windTime 		= _Time.y * float2(_WindEdgeFlutterFreqScale,1);
		float4	mdlPos			= AnimateVertex2(v.vertex,worldpos1,v.normal,windParams,wind,windTime);
		
		o.pos = UnityObjectToClipPos(mdlPos);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		
		o.spec = v.color;
		UNITY_TRANSFER_FOG(o,v.vertex);	
		
		//#ifndef LIGHTMAP_OFF
		//o.lmap = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
		//#endif
		
		return o;
	}
	ENDCG


	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest	
		#pragma multi_compile_fog	
		fixed4 frag (v2f i) : COLOR
		{
			fixed4 tex = tex2D (_MainTex, i.uv) * _DyeColor;
			
			fixed4 c;
			c.rgb = tex.rgb;
			c.a = tex.a;

			//brightness
			fixed3 finalColor = c.rgb * _Brightness;

			//saturation
			fixed luminance = 0.2125 * c.r + 0.7154 * c.g + 0.0721 * c.b;
			fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
			finalColor = lerp(luminanceColor, finalColor, _Saturation);

			//contrast
			fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
			finalColor = lerp(avgColor, finalColor, _Contrast);
			
			//#ifndef LIGHTMAP_OFF
			//fixed3 lm = DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap));
			//c.rgb *= lm;
			//#endif
			UNITY_APPLY_FOG(i.fogCoord, c);	
			return fixed4(finalColor,c.a);
		}
		ENDCG 
	}	
}
}


