Shader "Custom/MarbleShader"
{
    Properties
    {
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseThreshold("Noise Threshold", Range(0,1)) = 0.1
        [Space(10)]
        _Iterations("Iterations", float) = 5
        _ParallaxTex("Parallax Base Texture", 2D) = "white" {}
        _ParallaxDepth("Parallax amount", float) = 1    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 uvParallax : TEXCOORD1;
                float3 viewDirTangent : TEXCOORD2;
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _NoiseThreshold;

            float _Iterations;
            sampler2D _ParallaxTex;
            float4 _ParallaxTex_ST;
            float _ParallaxDepth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3x3 objectToTangent = float3x3(v.tangent, cross(v.tangent, v.normal), v.normal);
                o.viewDirTangent = mul(objectToTangent, ObjSpaceViewDir(v.vertex));

                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                o.uvParallax = TRANSFORM_TEX(v.uv, _ParallaxTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                i.viewDirTangent = normalize(i.viewDirTangent);

                float2 uv = i.uv;
                float2 uvParallax = i.uvParallax;

                float4 colore = float4(0, 0, 0, 0);
                float stepSize = float(1) / _Iterations;

                for (int p = 0; p < _Iterations; p++) {
                    float f = p;
                    float effect = stepSize * f;
                    float2 parallax_uv = uv - (i.viewDirTangent.xy * _ParallaxDepth * effect);
                    float value = tex2D(_NoiseTex, parallax_uv).r;
                    float tempCol = value * smoothstep(effect, 1, value);
                    colore += lerp(float4(1,1,1,1), float4(0,0,0,0), effect) * tempCol;
                }
                return colore;



                float mask = tex2D(_NoiseTex, uv).x;
                float col = step(_NoiseThreshold, mask);

                float parallax = 0;
                for (int j = 0; j < _Iterations; j++) {
                    float ratio = (float)j / _Iterations;

                    parallax += tex2D(_NoiseTex, uv + lerp(0, _ParallaxDepth, ratio) * normalize(i.viewDirTangent)) * lerp(1, 0, ratio);
                }
                parallax /= _Iterations;

                // sample the texture


                float baseCol = tex2D(_ParallaxTex, uvParallax) * mask + col + parallax;

                return col;
            }
            ENDCG
        }
    }
}
