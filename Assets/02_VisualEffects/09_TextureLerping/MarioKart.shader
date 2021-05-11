Shader "Custom/MarioKart"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _PatternTex ("Pattern Texture", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _RampSpeed("Ramp speed", Range(1,10)) = 5
        _RampSaturation("Ramp saturation", Range(1,4)) = 1
        [Space(10)]
        [HDR]_RimColor("Rim Color", Color) =  (1,1,1,1)
        _RimEffect("Rim Effect", Range(0,1)) = 1
    }
    SubShader
    {
        //TEXTUREPASS
        Pass
        {
            Cull Front

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _PatternTex;
            sampler2D _RampTex;

            float _RampSpeed;
            float _RampSaturation;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col  = tex2D(_MainTex, i.uv);
                fixed patt  = tex2D(_PatternTex,i.uv).r;
                fixed4 ramp = tex2D(_RampTex, fixed2(patt + _Time.x * _RampSpeed,1)) * _RampSaturation;

                fixed4 mixedCol = lerp(ramp, col, patt);

                return mixedCol;
            }
            ENDCG
        }

        
        Pass
        {
            Tags{"Queue" = "Transparent"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4 _RimColor;
            float _RimEffect;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex.xyz));
                return o;
            }
            
            float rimEffect(float3 uv, float3 normal)
            {
                float rim = 1 - abs(dot(uv,normal)) * _RimEffect;
                return rim;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed rimCol = rimEffect(i.uv,i.normal);
                return _RimColor * rimCol * rimCol;
            }
            ENDCG
        }
        

    }
}
