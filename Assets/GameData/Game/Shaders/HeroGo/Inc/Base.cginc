// HeroGo shader base include
// (c) 2016, Simon King

#ifdef USE_HALF_FLOAT
#define real	half
#define real2	half2
#define real3	half3
#define real4	half4
#else
#define real	float
#define real2	float2
#define real3	float3
#define real4	float4
#endif


void phong_term(in real3 vLight, in real3 vView, in real3 vNormal, in real fSpecPower, out real fDiffContrib, out real fSpecContrib)
{
	real3 vHalf = normalize(vView + vLight);// 1 alu
	real4 litV = lit(dot(vLight, vNormal), dot(vHalf, vNormal), fSpecPower);

	fDiffContrib = litV.y;
	fSpecContrib = litV.y * litV.z;
}

void phong_term_diff_only(in real3 vLight, in real3 vNormal, out real fDiffContrib)
{
	fDiffContrib = saturate(dot(vLight, vNormal));
}

fixed4 toon_term(in sampler2D _Ramp,in real3 vLight, in real3 vNormal,in fixed4 cAlbedo,in fixed4 cShadow,in fixed4 cLitten)
{
	real ndl = clamp(dot(vNormal, vLight) * 0.5f + 0.5f,0.05f,0.95f);
	fixed4 ramp = tex2D(_Ramp, fixed2(ndl, ndl)) + unity_AmbientSky;

	/// Gooch shading
	ramp.rgb = lerp(cShadow.rgb, cLitten.rgb, ramp.rgb);

	fixed4 c;
	c.rgb = cAlbedo.rgb * ramp.rgb;
	c.a = cAlbedo.a;

	return c;
}

fixed4 rim_lighting_term(real3 vNormal, real3 vView, real factor, real offest)
{
	real fresnel = 1.0 - saturate(dot(vNormal, vView));
	fresnel += fresnel * offest;
	return pow(fresnel, factor);
}
