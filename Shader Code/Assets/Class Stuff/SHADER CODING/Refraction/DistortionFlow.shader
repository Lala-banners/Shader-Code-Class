Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset] _FlowMap("Flow Map (RG, A noise)", 2D) = "black" {}
		[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}
    	_UJump ("U Jump per phase", Range(-0.25, 0.25)) = 0.25
    	_VJump("V Jump per phase", Range(-0.25, 0.25)) = 0.25
    	_Tiling("Tiling", Float) = 1
    	_Speed("Speed", Float) = 1
    	_FlowStrength("Flow Strength", Float) = 1
    	_FlowOffset("Flow Offset", Float) = 1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
		#include "Flow.cginc"
        sampler2D _MainTex, _FlowMap, _NormalMap;
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness, _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)

        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2 - 1;
        	flowVector *= _FlowStrength;
			float noise = tex2D(_FlowMap, IN.uv_MainTex).a;		
			float time = _Time.y * _Speed + noise;
			float2 jump = float2(_UJump, _VJump);

			//uv, flowVector, jump, flowOffset, tiling, time, bool flowB
			float3 uvwA = FlowUVW(IN.uv_MainTex, flowVector, jump, _FlowOffset, _Tiling, time, false);
			float3 uvwB = FlowUVW(IN.uv_MainTex, flowVector, jump, _FlowOffset, _Tiling, time, true);

			float normalA = UnpackNormal(tex2D(_NormalMap, uvwA.xy)) * uvwA.z;
			float normalB = UnpackNormal(tex2D(_NormalMap, uvwB.xy)) * uvwB.z;
			o.Normal = normalize(normalA + normalB);
        	
            // Albedo comes from a texture tinted by color
            fixed4 texA = tex2D (_MainTex, uvwA.xy) * uvwA.z;
            fixed4 texB = tex2D (_MainTex, uvwB.xy) * uvwB.z;

			fixed4 c = (texA + texB  * _Color);
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
