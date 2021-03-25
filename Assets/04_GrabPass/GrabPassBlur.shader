Shader "Custom/GrabPassBlur"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _Blur("Blur", Range(0.0,0.02)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        GrabPass {"_BackgroundTexture"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 uvgrab : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BackgroundTexture;
            float4 _Color;
            float _Blur;

            void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
            {
                float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                Out = lerp(Min, Max, randomno);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvgrab = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 projuv = i.uvgrab.xy / i.uvgrab.w;
                float4 col;
                //This is a blur effect, it s another technique that can be used with a grab pass
                const float grabSamples = 128;
                float noise = 0;
                Unity_RandomRange_float(i.uvgrab.xy,0,1,noise);
                for(float s = 0; s < grabSamples; s++)
                {
                    float2 offset = float2(cos(noise),sin(noise)) * _Blur;
                    //projuv.y += 0.1 * abs(sin(_Time.y));
                    col += tex2D(_BackgroundTexture,projuv + offset);
                    noise++;
                }

                return (col /= grabSamples) * _Color ;
            }
            ENDCG
        }
    }
}
