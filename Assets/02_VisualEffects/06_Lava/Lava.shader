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
        _HeightTex("Parallel Texture", 2D) = "white" {}
        _Parallax("Parallax amount", Range(0,2)) = 0.1
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
            float _Parallax;
            sampler2D _HeightTex;
            float4 _HeightTex_ST;

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
                o.uv_height = TRANSFORM_TEX(v.uv, _HeightTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Distortion texture is black and white so rgb are all of the same
                float distortion = tex2D(_DisTex, i.uv + _DisTex_ST.xy * _DisSPeed * _Time.y).r;
                i.uv.x += distortion / _DisValue;
                //i.uv.y += distortion / _DisValue;

                float parallax = 0;
                for (int j = 0; j < _Iterations; j++) {
                    float ratio = (float)j / _Iterations;
                    parallax += tex2D(_HeightTex, i.uv_height + lerp(0, _Parallax, ratio) * normalize(i.viewDirTangent)) * lerp(1, 0, ratio);
                }
                parallax /= _Iterations;

                fixed4 col = tex2D(_MagmaTex, i.uv) + parallax;
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _RockTex;
            float4 _RockTex_ST;
            
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
                
                o.uv = TRANSFORM_TEX(v.uv, _RockTex);
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
