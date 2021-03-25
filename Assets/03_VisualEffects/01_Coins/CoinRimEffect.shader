﻿Shader "VisualEffect/CoinRimEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GoldTex("Gold Texture", 2D) = "white"{}
        [Space(10)]
        _Range("Gold Range",Range(1,5)) = 1
        _Speed("Gold Speed",Range(-1,1)) = 0
        _Brightness("Gold Brightness",Range(0.0,0.5)) = 0.1
        _Saturation("Gold Saturation",Range(0.5,1.0)) = 0.5
        [Space(10)]
        _Color("Rim Color",Color) = (1,1,1,1)
        _Rim ("Rim effect",Range(0,1)) = 1
    }
    SubShader
    {        
        Pass
        {
            Tags
            {
                "Queue" = "Geometry"
            }

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
                float4 uvv: TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _GoldTex;
            float4 _MainTex_ST;
            float _Range;
            float _Speed;
            float _Brightness;
            float _Saturation;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvv = ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 projUv = i.uvv.xy / i.uvv.w;

                float4 col = tex2D(_GoldTex, projUv) * tex2D(_MainTex, i.uv) / _Saturation;

                return col + _Brightness;
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "Queue"= "Transparent"
            }

            ZWrite Off
            Blend SrcColor DstColor //the effect is additive

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 normal : NORMAL;
                float4 vertex : POSITION;   
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;

            };

            float4 _Color;
            float _Rim;

            v2f vert (appdata i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, i.normal.xyz));
                o.uv = normalize(_WorldSpaceCameraPos - mul((float3x3)unity_ObjectToWorld, i.vertex.xyz));
                return o;
            }

            float rimEffect(float3 uv, float3 normal)
            {
                float col = 1 - abs(dot(uv,normal)) * _Rim;
                return col;
            }

            fixed4 frag (v2f o) : Color
            {
                fixed rimColor = rimEffect(o.uv, o.normal.xyz);
                return _Color * rimColor * rimColor;
            }
            ENDCG
        }
    }
}
