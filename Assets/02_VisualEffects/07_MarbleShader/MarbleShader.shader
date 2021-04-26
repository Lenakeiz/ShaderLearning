Shader "Custom/MarbleShader"
{
    Properties
    {
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseThreshold("Noise Threshld", Range(0,1)) = 0.5
        _Iterations("Iterations", float) = 5
        _ParallaxDepth("Parallax Depth", float) = 1    
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; //Adding normal
                float3 tangent : TANGENT; //Adding tangent
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDirTangent : TEXCOORD1;
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _Iterations;
            float _ParallaxDepth;
            float _NoiseThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3x3 objectToTangent = float3x3(v.tangent, cross(v.tangent, v.normal), v.normal);
                o.viewDirTangent = mul(objectToTangent, ObjSpaceViewDir(v.vertex));

                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            float getDistance(float2 input)
            {
                return sqrt(input.x * input.x + input.y * input.y);
            }

            float2 normalizeUV(float2 uvInput)
            {
                return ((uvInput - 0.5) * 2);
            }

            float4 frag(v2f i) : SV_Target
            {
                i.viewDirTangent = normalize(i.viewDirTangent);
                
                float2 uv_norm = normalizeUV(i.uv);
                float2 uv = i.uv;

                float4 color = float4(0, 0, 0, 0.5);
                float stepSize = float(1) / _Iterations;
                float4 mask = tex2D(_NoiseTex, uv);
                
                float distance = getDistance(uv_norm);

                for (int p = 0; p < _Iterations; p++) {
                    float ratio = stepSize * (float)p; //ratio moves us step by step in the viewdirection space
                    float2 parallax_uv = uv - (i.viewDirTangent.xy) * lerp(0.0, _ParallaxDepth, ratio);//move uvs according to a depth
                    float parallaxDistance = getDistance(normalizeUV(parallax_uv));//get current distance from the center of the calculated uv 
                    float4 value = tex2D(_NoiseTex, parallax_uv);//Sample the gradient mask
                    value.a = 0.5;
                    float tempCol = value * step(parallaxDistance, lerp(_NoiseThreshold, 0.0, ratio));//calculate the color by controlling for the cutoff
                    color += tempCol;
                }
                //color /= _Iterations;
                return color;

            }
            ENDCG
        }
    }
}
