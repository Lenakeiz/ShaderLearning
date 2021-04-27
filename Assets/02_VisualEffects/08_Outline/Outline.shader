Shader "Custom/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Space(10)]
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineValue("Outline Value", Range(0.0, 0.2)) = 0.1
    }
    SubShader
    {
        Pass
        {
            Tags { "Queue" = "Transparent"}
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _OutlineColor;
            float _OutlineValue;

            float4 calculateOutline(float4 vertexPos, float outValue)
            {
                float4x4 scale = float4x4
                (
                    1 + outValue, 0, 0, 0,
                    0, 1 + outValue, 0, 0,
                    0, 0, 1 + outValue, 0,
                    0, 0, 0, 1 + outValue
                );
                return mul(scale, vertexPos);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float t = _Time.y;
                _OutlineValue = (sin(t * 1.5) * 0.5 + 0.5) * _OutlineValue;
                float4 vertexPos = calculateOutline(v.vertex, _OutlineValue);
                // float4 objPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1));
                // float dist = distance(_WorldSpaceCameraPos, objPos.xyz) / _ScreenParams.g;
                // vertexPos = float4(v.vertex.xyz + v.normal * 0.25 * _OutlineValue,1);
                o.vertex = UnityObjectToClipPos(vertexPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y;
                // sample the texture
                _OutlineColor.a = sin(t * 1.5) * 0.5 + 0.5;
                
                return _OutlineColor;
            }
            ENDCG
        }

         Pass
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Transparent+1"}
            Blend SrcAlpha OneMinusSrcAlpha

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

    }
}
