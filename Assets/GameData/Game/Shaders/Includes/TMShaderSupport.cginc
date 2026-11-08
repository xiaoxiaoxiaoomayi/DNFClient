#ifndef TMSHADER_SUPPORT_INCLUDED
#define TMSHADER_SUPPORT_INCLUDED

fixed4 black_white(fixed4 col)
{
	fixed luminosity = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
	return fixed4(luminosity.xxx, col.a);
}


//#define BLACKWHITE 

#ifdef BLACKWHITE
	#define OUTPUT_COL(col) black_white(col)
#else
	#define OUTPUT_COL(col) col
#endif


inline float3 SafeNormalize(float3 inVec)
{
	float dp3 = max(0.001f, dot(inVec, inVec));
	return inVec * rsqrt(dp3);
}

#endif


