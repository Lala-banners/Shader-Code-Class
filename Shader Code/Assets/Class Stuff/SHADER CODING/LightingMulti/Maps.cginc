#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

struct appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
	float4 tangent: TANGENT; //xyz = tangent dir, w tangent sign
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 tangent : TEXCOORD2;
	float3 bitangent : TEXCOORD3;
	float3 wPos : TEXCOORD4;
	//Gives world coords of the light (fade effect)
	LIGHTING_COORDS(5, 6) //No ;
};

sampler2D _Albedo;
sampler2D _Normals;
float4 _Albedo_ST;
float4 _Color;
float _Gloss;
float _glowMag;
float _glowFeq;
float _NormalIntensity;

v2f vert(appdata v)
{
	v2f o;
	o.uv = TRANSFORM_TEX(v.uv, _Albedo);
	o.vertex = UnityObjectToClipPos(v.vertex);

	o.normal = UnityObjectToWorldNormal(v.normal);
	//Tangent - right angle to perpendictular
	o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
	o.bitangent = cross(o.normal, o.tangent);
	//Flip/mirror object - works
	o.bitangent *= v.tangent.w * unity_WorldTransformParams.w;

	o.wPos = mul(unity_ObjectToWorld, v.vertex);

	TRANSFER_VERTEX_TO_FRAGMENT(o);
	return o;
}

fixed4 frag(v2f i) : SV_Target
{
	//Textures Stuff
	float3 albedo = tex2D(_Albedo, i.uv).rgb; //Sample colour from texture
	//Change tint colur of texture
	float3 surfaceColour = albedo * _Color.rgb;

	//return float4(surfaceColour, 0);

	float3 tangentSpaceNormal = UnpackNormal(tex2D(_Normals, i.uv));
	tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _NormalIntensity)); //Makes weird/creepy 3D effect

	//Change from local space to world space
	float3x3 mtxTangToWorld =
	{
		i.tangent.x, i.bitangent.x, i.normal.x,
		i.tangent.y, i.bitangent.y, i.normal.y,
		i.tangent.z, i.bitangent.z, i.normal.z
	};
	float3 N = mul(mtxTangToWorld, tangentSpaceNormal); 


#ifdef USE_LIGHTING
	//diffuse lighting
	float3 L = normalize(UnityWorldSpaceLightDir(i.wPos)); //_WorldSpaceLightPos0.xyz;//(a) direction 
	float attenuation = LIGHT_ATTENUATION(i);

	float3 lambert = saturate(dot(N, L));
	float3 diffuseLight = (attenuation * lambert) * _LightColor0.xyz;

	//Normalize Lighting
	float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
	float3 H = normalize(L + V);

	//Specular
	float3 specularLight = saturate(dot(H,N));// * (lambert > 0);
	float specularExponent = exp2(_Gloss * 11) + 2;
	specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation;
	specularLight = pow(specularLight, specularExponent) * _Gloss; //specular exponent
	specularLight *= _LightColor0.xyz;


	return float4(diffuseLight * surfaceColour + specularLight, 1);

#else
	#ifdef IS_IN_BASE_PASS
	return surfaceColour;
	#else
	return 0;
	#endif
#endif

	//return float4(diffuseLight,1);
	// sample the texture
	//fixed4 col = tex2D(_MainTex, i.uv);
	//return col;
}