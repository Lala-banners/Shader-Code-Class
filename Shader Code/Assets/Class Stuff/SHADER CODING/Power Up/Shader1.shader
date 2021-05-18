Shader "MyShaders/Shader1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("The Color", Color) = (1,0,0,1)
        _ColorB("The Color", Color) = (0,1,0,1) //Syntax to manually change colour
        _Scale("UV Scale", Float) = 1
        _Offset ("UV Offset", Float) = 0
        _StartColor("Color Start", Range(0, 1)) = 1
        _EndColor("Color End", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" //tag to inform the render pipeline
                "Queue" = "Transparent"} //Changes render order
        //Tags { "RenderType" = "Transparent" + ... } To make transparent

        Pass
        {
            Cull Off //Back front
            ZWrite Off //Buffer
            //ZTest Always
            Blend One One //Additive transparency
            //Blend DstColor Zero

            //C for graphics
            CGPROGRAM //Shader code

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData //brings things in from properties to CGPROGRAM
            {
                float4 vertex : POSITION; //Position of each vertice.
                float3 normals : NORMAL; //normal of the vertex
                float2 uv : TEXCOORD0; //uv0 diffuse/normal map textures
            };

            struct v2f //vertex to fragment - send info between vertex and fragment sub-shaders
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define TAU 6.3

            //float4 is array of 4 floats
            float4 _ColorA;
            float4 _ColorB;
           
            float _EndColor;
            float _StartColor;

            float _Scale;
            float _Offset;

            //#pragma is how Unity knows vert and frag methods
            v2f vert (MeshData v) //Appdata from properties to the shader
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals); //mull((float3x3)unity_ObjectToWorld, v.normals);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv; // *_Scale;
                return o;
            }

            //Inverse lerp
            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            float4 frag(v2f i) : SV_Target //#pragma is how Unity knows vert and frag methods
            {
                //float t = saturate(InverseLerp(_StartColor, _EndColor, i.uv.x)); //whatever uv coord will return t (greyscale)
                //return t;
                //float t = abs(frac(i.uv.x * 5) * 2 - 1); //Looping
                
                //x secs/20
                //y secs
                //z secs * 2
                //w secs * 3

                float xOffset = cos(i.uv.x * TAU * 8) * 0.01;

                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5f + 0.5f; //Make zig zag

                t *= 1 - i.uv.y;
                float topBottomRemover = (abs(i.normal.y) < 0.999f);
                float waves = t * topBottomRemover;
                //return waves;
                //lerp & swizzle - blend two colors using UV
                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y); //Basically made ColorA the main color, 0.5 makes the color halfway between ColorA & ColorB
                return gradient * waves;
                //Blend between two colors using UV
                //float4 outColor = lerp(_ColorA, _ColorB, i.uv.x);
                //float4 col = float4(i.uv.xxx, 1); 
            }
            ENDCG //Shader code ends here

        }
    }
}
