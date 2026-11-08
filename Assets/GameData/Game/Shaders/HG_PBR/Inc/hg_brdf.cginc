
#include "hg_base.cginc"

real _pow_5(real v)
{
	real pow_2 = v*v;
	return pow_2 * pow_2 * v;
}

real _pow_3(real v)
{
	return v * v * v;
}

real _pow_2(real v)
{
	return v * v;
}

float3 spec_fresnel_roughness(float3 specularColor, float a, float3 h, float3 v)
{
	return (specularColor + (max(1.0f - a, specularColor) - specularColor) * _pow_5(1 - saturate(dot(v, h))));
}

/// Schlick
real3 spec_fresnel(real3 cSpecular, real3 Hn, real3 Vn)
{
	real factor = 1.0f - saturate(dot(Vn, Hn));
	return (cSpecular + (1.0f - cSpecular) * _pow_5(factor));
}

/// GGX
real spec_distribution(real a, real NdH)
{
	// Isotropic ggx.
	float a2 = a*a;
	float NdH2 = NdH * NdH;

	float denominator = NdH2 * (a2 - 1.0f) + 1.0f;
	denominator *= denominator;
	denominator *= PI;

	return a2 / denominator;
}

/// Smith schlick-GGX.
float spec_geometric(float a, float NdV, float NdL)
{
	// Smith schlick-GGX.
	float k = a * 0.5f;
	float GV = NdV / (NdV * (1 - k) + k);
	float GL = NdL / (NdL * (1 - k) + k);

	return GV * GL;
}

real3 specular_term_brdf(real3 specularColor, real3 Hn, real3 Vn, real3 Ln, real a, real NdL, real NdV, real NdH, real VdH, real LdV)
{
	return ((spec_distribution(a, NdH) * spec_geometric(a, NdV, NdL)) * spec_fresnel(specularColor, Vn, Hn)) / (4.0f * NdL * NdV);
	//return spec_distribution(a, NdH) * spec_geometric(a, NdV, NdL);
}

float3 diffuse_term_brdf(float3 cAlbedo)
{
	return cAlbedo / PI;
}

real3 compute_brdf(real3 cAlbedo, real3 cSpecular, real3 cLight, real3 Nn, real roughness, real3 Ln, real3 Vn)
{
	// Compute some useful values.
	real NdL = saturate(dot(Nn, Ln)) + 0.001f;
	real NdV = saturate(dot(Nn, Vn)) + 0.001f;
	real3 Hn = normalize(Ln + Vn);
	real NdH = saturate(dot(Nn, Hn));
	real VdH = saturate(dot(Vn, Hn));
	real LdV = saturate(dot(Ln, Vn));

	real a = max(0.001f, roughness * roughness);

	real3 cDiff = diffuse_term_brdf(cAlbedo);
	real3 cSpec = specular_term_brdf(cSpecular, Hn, Vn, Ln, a, NdL, NdV, NdH, VdH, LdV);

	return cLight * NdL * (cDiff * (1.0f - cSpec) + cSpec);
}

float3 spec_fresnel_assistant_light(float3 specularColor, float3 h, float3 v, float mask)
{
	specularColor = saturate_color(specularColor, 1);
	return saturate((specularColor + _pow_3(1 - saturate(dot(v, h))))) * mask * 4;
}

real3 pbr_lighting(sampler2D _LitSphere, real4 albedo, real4 bump, real4 param,
	real3 Nn, real3 Vn, real3 Ln, real3 lightCol, float lightDist,
	real lightIntensity, real ambientIntensity, real reflectIntensity)
{
	real metallic = param.x*0.8f;
	real roughness = 1 - param.y*0.7f;

	// Lerp with metallic value to find the good diffuse and specular.
	float3 realAlbedo = albedo - albedo * metallic;

	// 0.03 default specular value for dielectric.
	float3 realSpecularColor = lerp(0.03f, albedo, metallic);

	float3 light1 = compute_brdf(realAlbedo, realSpecularColor, _LightColor0, Nn, roughness, Ln, Vn);

	float attenuation = PI / (lightDist * lightDist);
	float mipIndex = roughness * roughness * 64.0f;

	float3 envColor = tex2Dlod(_LitSphere, real4(get_envmap_uv_cylindrical(-Vn, Nn, 1), 1, mipIndex));
	fixed3 fresnelCol = realSpecularColor * envColor * (1 - metallic);
	fixed3 envFresnel = max(spec_fresnel_roughness(fresnelCol, roughness * roughness, Nn, Vn), param.z*spec_fresnel_assistant_light(fresnelCol, Nn, Vn, dot(float3(Vn.z, Vn.y, -Vn.x), Nn)));

	real3 col;
	col = lightIntensity * light1 + realAlbedo * ambientIntensity + envFresnel * envColor * reflectIntensity;
	return col;
}

real3 pbr_lighting_low(sampler2D _LitSphere, real4 albedo, real4 bump, real4 param, real3 Nn, real3 Vn, real3 Ln, real3 lightCol,
	float lightDist, real lightIntensity, real ambientIntensity, real reflectIntensity)
{
	real metallic = param.x;
	real roughness = 1 - param.y *0.5f;

	// Lerp with metallic value to find the good diffuse and specular.
	float3 realAlbedo = albedo - albedo * metallic;

	// 0.03 default specular value for dielectric.
	float3 realSpecularColor = lerp(0.03f, albedo, metallic);

	float3 light1 = compute_brdf(realAlbedo, realSpecularColor, _LightColor0, Nn, roughness, Ln, Vn);

	float attenuation = PI / (lightDist * lightDist);
	float mipIndex = roughness * roughness * 64.0f;

	fixed3 fresnelCol = realSpecularColor * 0.5 * (1 - metallic);
	fixed3 envFresnel = spec_fresnel_roughness(fresnelCol, roughness * roughness, Nn, Vn);

	real3 col;
	col.rgb = lightIntensity * light1 + realAlbedo * ambientIntensity + envFresnel * 0.5f * reflectIntensity;

	return col;
}
