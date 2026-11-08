#ifndef _BASE_INC_
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
#define _BASE_INC_

//#ifdef USE_HALF_FLOAT
//#define real	half
//#define real2	half2
//#define real3	half3
//#define real4	half4
//#define real1x2	half1x2
//#define real2x2	half2x2
//#define real3x2	half3x2
//#define real4x2	half4x2
//#define real1x3	half1x3
//#define real2x3	half2x3
//#define real3x3	half3x3
//#define real4x3	half4x3
//#define real1x4	half1x4
//#define real2x4	half2x4
//#define real3x4	half3x4
//#define real4x4	half4x4
//#else
#define real	float
#define real2	float2
#define real3	float3
#define real4	float4
#define real1x2	float1x2
#define real2x2	float2x2
#define real3x2	float3x2
#define real4x2	float4x2
#define real1x3	float1x3
#define real2x3	float2x3
#define real3x3	float3x3
#define real4x3	float4x3
#define real1x4	float1x4
#define real2x4	float2x4
#define real3x4	float3x4
#define real4x4	float4x4
//#endif

#define PI			3.1415926f
#define PI_2		6.2831852f

float2 get_uv_cylindrical(in float3 v, in float flipEnvMap)
{
	//I assume envMap texture has been flipped the WebGL way (pixel 0,0 is a the bottom)
	//therefore we flip wcNorma.y as acos(1) = 0
	float phi = acos(-v.y);
	float theta = atan2(flipEnvMap * v.x, v.z) + PI;
	return float2(theta / PI_2, phi / PI);
}

float2 get_envmap_uv_cylindrical(in float3 vView, in float3 vNormal, in float flipEnvMap)
{
	float3 r = reflect(vView, vNormal);
	//I assume envMap texture has been flipped the WebGL way (pixel 0,0 is a the bottom)
	//therefore we flip wcNorma.y as acos(1) = 0
	return get_uv_cylindrical(r, flipEnvMap);
}

float4 encode_to_rgba(float fValue)
{
	float4 vShift = float4(256.0f * 256.0f * 256.0f, 256.0f * 256.0f, 256.0f, 1.0f);
	float4 vMask = float4(0.0f, 1 / 256.0f, 1 / 256.0f, 1 / 256.0f);
	float4 vRes = frac(fValue * vShift);
	vRes -= vRes.xxyz * vMask;
	return vRes.wzyx;
}

float decode_from_rgba(float4 rgba)
{
	float4 vShift = float4(1.0f / (256.0f * 256.0f * 256.0f), 1.0f / (256.0f * 256.0f), 1.0f / 256.0f, 1.0f);
	return dot(rgba.wzyx, vShift);
}

float3 saturate_color(float3 col,float factor)
{
	return lerp(col.rgb, col.rgb * normalize(col.rgb), factor);
}

#endif
