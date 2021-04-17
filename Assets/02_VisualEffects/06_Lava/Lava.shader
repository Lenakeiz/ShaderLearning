Shader "Custom/Lava"
{
    Properties
    {
        _RockTex ("Rock Texture", 2D) = "white" {}
        _MagmaTex ("Magma Texture", 2D) = "white" {}
        _DisTex ("Distortion Texture", 2D) = "white" {}
        [Space(10)]
        _DisValue ("Distortion Value", Range(2,10)) = 3
        _DisSPeed ("Distortion Speed", Range(-0.4, 0.4)) = 0.1
        [Space(10)]
        _WaveSpeed("Wave Speed", Range(0,5)) = 1
        _WaveFrequency("Wave Frequency", Range(0,5)) = 1
        _WaveAmplitude("Wave Amplitude", Range(0,1)) = 0.5
        [Space(10)]
        _Iterations("Iterations", float) = 5
        _ParallaxTex("Parallel Texture", 2D) = "white" {}
        _ParallaxDepth("Parallax amount", Range(0,0.4)) = 0.1
        [Space(10)]
        _HeightMapRockTex("Height Map Rock Texture", 2D) = "white"{}
        _HeightScale("Height scale", Range(0.005, 0.1)) = 0.08
        _HeightSamples("Parallax samples", Range(10, 100)) = 40
    }
    SubShader
    {
        // First pass will take the magma texture and apply a distortion to it
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //This are necessary to calculate the tangent view space
                float3 normal : NORMAL; //Adding normal
                float4 tangent : TANGENT; //Adding tangent
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDirTangent : TEXCOORD1;
                float2 uv_height : TEXCOORD2;
            };

            sampler2D _MagmaTex;
            float4 _MagmaTex_ST;
            sampler2D _DisTex;
            float4 _DisTex_ST;

            float _Iterations;
            float _ParallaxDepth;
            sampler2D _ParallaxTex;
            float4 _ParallaxTex_ST;

            float _DisValue;
            float _DisSPeed;

            float _WaveSpeed;
            float _WaveFrequency;
            float _WaveAmplitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                //o.vertex.y += _WaveAmplitude * sin((-worldPos.z + (_Time.y * _WaveSpeed)) * _WaveFrequency);
                //o.vertex.y += _WaveAmplitude * cos((-worldPos.x + (_Time.y * _WaveSpeed)) * _WaveFrequency);

                float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDir = v.vertex.xyz - objCam.xyz;
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
                o.viewDirTangent = float3(
                    dot(viewDir, v.tangent.xyz),
                    dot(viewDir, bitangent.xyz),
                    dot(viewDir, v.normal.xyz)
                    );


                o.uv = TRANSFORM_TEX(v.uv, _MagmaTex);
                o.uv_height = TRANSFORM_TEX(v.uv, _ParallaxTex);
                return o;
            }

            fixed4 Overlay(fixed4 a, fixed4 b)
            {
                fixed4 r = a < .5 ? 2.0 * a * b : 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
                r.a = b.a;
                return r;
            }

            fixed4 Darken(fixed4 a, fixed4 b)
            {
                fixed4 r = min(a, b);
                r.a = b.a;
                return r;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Distortion texture is black and white so rgb are all of the same
                float distortion = tex2D(_DisTex, i.uv + _DisTex_ST.xy * _DisSPeed * _Time.y).r;
                i.uv += distortion / _DisValue;

                float4 parallaxColor = 0;
                for (int j = 0; j < _Iterations; j++) {
                    float ratio = (float)j / _Iterations;
                    parallaxColor += tex2D(_ParallaxTex, i.uv + lerp(0, _ParallaxDepth, ratio) * normalize(i.viewDirTangent)) * lerp(1,0,ratio);
                }
                parallaxColor /= _Iterations;

                float4 baseColor = tex2D(_MagmaTex, i.uv);

                fixed4 col = Darken(baseColor, parallaxColor ) * 0.6 + Overlay(baseColor, parallaxColor) * 0.4;
                return col;
                // For visualization purposes
                // return float4(i.uv.x,i.uv.y, 0,1);
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "Queue" = "Transparent"
            }

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; //Adding normal
                float4 tangent : TANGENT; //Adding tangent
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDirTangent : TEXCOORD1;
                float2 uv_height : TEXCOORD2;
            };

            sampler2D _RockTex;
            float4 _RockTex_ST;

            sampler2D _HeightMapRockTex;
            float4 _HeightMapRockTex_ST;
            
            float _HeightScale;
            float _HeightSamples;

            float _WaveSpeed;
            float _WaveFrequency;
            float _WaveAmplitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                //o.vertex.y += _WaveAmplitude * sin((-worldPos.z + (_Time.y * _WaveSpeed)) * _WaveFrequency);
                //o.vertex.y += _WaveAmplitude * cos((-worldPos.x + (_Time.y * _WaveSpeed)) * _WaveFrequency);
                
                float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDir = v.vertex.xyz - objCam.xyz;
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
                o.viewDirTangent = float3(
                    dot(viewDir, v.tangent.xyz),
                    dot(viewDir, bitangent.xyz),
                    dot(viewDir, v.normal.xyz)
                    );

                o.uv = TRANSFORM_TEX(v.uv, _RockTex);
                o.uv_height = TRANSFORM_TEX(v.uv, _HeightMapRockTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_RockTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
