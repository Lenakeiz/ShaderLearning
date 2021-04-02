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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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
