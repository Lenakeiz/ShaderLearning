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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MagmaTex;
            sampler2D _DisTex;
            float4 _MagmaTex_ST;

            float _DisValue;
            float _DisSPeed;

            float _WaveSpeed;
            float _WaveFrequency;
            float _WaveAmplitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.vertex.y += _WaveAmplitude * sin((-worldPos.z + (_Time.y * _WaveSpeed)) * _WaveFrequency);
                o.vertex.y += _WaveAmplitude * cos((-worldPos.x + (_Time.y * _WaveSpeed)) * _WaveFrequency);

                o.uv = TRANSFORM_TEX(v.uv, _MagmaTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Distortion texture is black and white so rgb are all of the same
                float distortion = tex2D(_DisTex, i.uv + _DisSPeed * _Time.y).r;
                i.uv.x += distortion / _DisValue;
                i.uv.y += distortion / _DisValue;
                fixed4 col = tex2D(_MagmaTex, i.uv);
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

                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.vertex.y += _WaveAmplitude * sin((-worldPos.z + (_Time.y * _WaveSpeed)) * _WaveFrequency);
                o.vertex.y += _WaveAmplitude * cos((-worldPos.x + (_Time.y * _WaveSpeed)) * _WaveFrequency);

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
