Shader "Custom/GrabPass"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _Blur("Blur", Range(0.0,0.02)) = 0
        _Amount ("Amount", float) = 25
        _WaveSpeed("Wave Speed", range(.50, 50)) = 20
        _WaveAmount("Wave Amount", range(0, 20)) = 10
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
                float4 uvgrab_center : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BackgroundTexture;
            float4 _Color;
            float _Blur;
            float _Amount;
            float _WaveSpeed;
            float _WaveAmount;

            void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
            {
                float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                Out = lerp(Min, Max, randomno);
            }

            v2f vert (appdata v)
            {
                v2f o;
                //Playing around with vertices
                //v.vertex.y = v.vertex.y * abs(sin(_Time.y));
                //v.vertex.x = v.vertex.x * abs(sin(_Time.y));
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex.y = o.vertex.y + 0.2 * sin(_Time.y);
                //Requires the input in the clip space
                o.uvgrab = ComputeGrabScreenPos(o.vertex);
                o.uvgrab_center = ComputeGrabScreenPos(UnityObjectToClipPos(float4(0.0,0.0,0,1)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Getting rid of the projection
                //i.uvgrab.xyz = i.uvgrab.xyz * i.uvgrab.w;
                //Similar to tex2D by divides the coordinate of the texture by w (to calculate for the projection)
                //i.uvgrab.y = i.uvgrab.y + 0.2*abs(sin(_Time.y));
                float2 projuv = i.uvgrab.xy / i.uvgrab.w;
                float2 projuv_center = i.uvgrab_center.xy / i.uvgrab_center.w;
                //Create a ripple from the center of the quad texture
                //Calculate distance from the center
                float mappedUV = tex2D(_BackgroundTexture,projuv);
                float wavesize = 2;
                //return 0.5 * (sin(mappedUV / wavesize + _Time.y) + 1);

                float timeR = _Time.y * _WaveSpeed;
                float amt = _Amount/1000;

                float2 uvcentered = projuv_center - projuv;
                float distanceC = sqrt(dot(uvcentered,uvcentered));
                float ang = distanceC * _WaveAmount - timeR;
                uvcentered = projuv + normalize(uvcentered) * sin(ang) * amt;

                return tex2D(_BackgroundTexture,uvcentered);

                float distanceFromOrigin = distance(mappedUV, float2(0.5,0.5));
                //Calculating the offset using a sinwave
                float offset = (sin(_Time.y + distanceFromOrigin / wavesize)) * 0.5;
                //projuv.x += offset;
                //projuv.x = frac(projuv.x);
                fixed4 col = 1 - tex2D(_BackgroundTexture,projuv);
                return col;

                //This is a blur effect, it s another technique that can be used with a grab pass
                const float grabSamples = 32;
                float noise = 0;
                Unity_RandomRange_float(i.uvgrab.xy,0,1,noise);
                for(float s = 0; s < grabSamples; s++)
                {
                    float2 offset = float2(cos(noise),sin(noise)) * _Blur;
                    //projuv.y += 0.1 * abs(sin(_Time.y));
                    col += tex2D(_BackgroundTexture,projuv + offset);
                    noise++;
                }

                return (col /= grabSamples) * _Color;
            }
            ENDCG
        }
    }
}
