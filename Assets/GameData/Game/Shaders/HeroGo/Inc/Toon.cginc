// HeroGo shader toon include
// Include all common toon calculate method
// (c) 2016, Simon King

#ifndef __HG_TOON_INC_H__
#define __HG_TOON_INC_H__

fixed4 _ShadowColor;
fixed4 _LittenColor;

//Lighting Ramp
sampler2D _Ramp;

half _RimRange;
half _RimFactor;

#endif

#pragma lighting Cartoon exclude_path:prepass
inline half4 LightingCartoon(SurfaceOutput s, half3 lightDir, half atten)
{
#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
#endif

	/// Ramp shading
	fixed ndl = dot(s.Normal, lightDir)*0.5 + 0.5;
	fixed3 ramp = tex2D(_Ramp, fixed2(ndl, ndl));

	/// Gooch shading
	ramp = lerp(_ShadowColor.rgb, _LittenColor.rgb, ramp);

	fixed4 c;
	c.rgb = s.Albedo * atten * _LightColor0.rgb * ramp;
	c.a = 1;

	return c;
}

#pragma lighting CartoonRim exclude_path:prepass
inline half4 LightingCartoonRim(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
{
#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
#endif

	/// Ramp shading
	fixed ndl = dot(s.Normal, lightDir)*0.5 + 0.5;
	fixed3 ramp = tex2D(_Ramp, fixed2(ndl, ndl));

	/// Gooch shading
	ramp = lerp(_ShadowColor.rgb, _LittenColor.rgb, ramp);

	fixed4 c;
	c.rgb = s.Albedo * (atten)* _LightColor0.rgb * ramp;
	c.a = saturate(1 - step(dot(s.Normal, viewDir), _RimRange) + _RimFactor);

	return c;
}

