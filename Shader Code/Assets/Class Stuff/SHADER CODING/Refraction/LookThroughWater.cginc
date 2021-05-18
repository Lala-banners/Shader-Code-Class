#if !defined(LOOK_THROUGH_WATER_INCLUDED)
#define LOOK_THROUGH_WATER_INCLUDED

sampler2D _CamDepthTex;

float3 ColourBelowWater(float4 screenPos)
{
    float2 uv = screenPos.xy / screenPos.w;
    float bgDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CamDepthTex, uv));
    float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
    float depthDist = bgDepth - surfaceDepth;
    
    return depthDist.xxx / 20;
}

#endif