Shader "Custom/GrabPassRipple"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _Amount ("Amount", float) = 10
        _WaveSpeed("Wave Speed", range(0, 15)) = 5
        _WaveAmount("Wave Amount", range(0, 50)) = 5
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
                //Similar to tex2D by divides the coordinate of the texture by w (to calculate for the projection)
                float2 projuv = i.uvgrab.xy / i.uvgrab.w;
                float2 projuv_center = i.uvgrab_center.xy / i.uvgrab_center.w;

                //Create a ripple from the center of the quad texture, in the future I can try to adjust the center coordinates to a click on the mesh
                //Calculate distance from the center
                float mappedUV = tex2D(_BackgroundTexture,projuv);

                float timeR = _Time.y * _WaveSpeed;
                float amount = _Amount/1000;

                float2 uvcentered = projuv_center - projuv;
                float distanceC = sqrt(dot(uvcentered,uvcentered));
                float displacement = distanceC * _WaveAmount - timeR;
                // Add to the current uv a vector that is radial with respect to the center and apply the sin wave to this
                uvcentered = projuv + normalize(uvcentered) * sin(displacement) * amount;

                return 1 - tex2D(_BackgroundTexture,uvcentered);
            }
            ENDCG
        }
    }
}
