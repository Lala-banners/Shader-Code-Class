Shader "Unlit/LightingMulti"
{
    Properties
    {
        _Albedo ("Albedo", 2D) = "white" {}
        [NoScaleOffset]_Normals("Normals", 2D) = "Bump"{}
        _NormalIntensity("Normal Intensity", Range(0,1)) = 1

        _Gloss("Gloss", Range(0,1)) = 1 //Roughness is Gloss 
        _Color("Color", Color) = (1,1,1,1)
        _glowMag("glowMag", Range(0,1)) = 0.5
        _glowFreq("glowFreq", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        //Base pass
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}     
            CGPROGRAM
            #define IS_IN_BASE_PASS //Tells if in base pass or forward pass
            #pragma vertex vert
            #pragma fragment frag

            #include "Maps.cginc"
            
            ENDCG
        }

        //Add pass
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One // src * 1 + dst * 1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd //dad

            #include "Maps.cginc"
            
            ENDCG
        }
    }
}
