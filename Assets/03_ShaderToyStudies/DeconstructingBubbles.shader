// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// This is a study I have been doing to port simpler shadertoy to unity. Most of them are based on image effects and needs to be placed on the camera.
// I am following a tutorial and I ll come back to this
// https://www.shadertoy.com/view/4dl3zn

Shader "Custom/DeconstructingBubbles" {

    SubShader {
   
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
           
            struct v2f{
                float4 position : SV_POSITION;
            };
           
            v2f vert(float4 v:POSITION) : SV_POSITION {
                v2f o;
                o.position = UnityObjectToClipPos (v);
                return o;
            }

            float4 rgb(float r, float g, float b, float alpha)
            {
	            return float4(r / 255.0, g / 255.0, b / 255.0, alpha);
            }

            float hash(float seed)
            {
	            // Return a "random" number based on the "seed"
                return frac(sin(seed) * 43758.5453);
            }

            float2 hashPosition(float seed)
            {
	            // Return a "random" position based on the "seed"
	            return float2(hash(seed), hash(seed * 2.0));
            }

            float sdCircle( float2 p, float2 offset, float r ) 
            {
                return length(p-offset)-r;
            }
            
            float4 frag(v2f i) : SV_Target {
                
                //This is an attempt to write a single circle on the screen
                float2 uv = (2.0 * i.position.xy - _ScreenParams.xy)/_ScreenParams.y;//We map the coordinate from 0 to 1

                float3 backgroundColor = lerp(float3(0.3,0.1,0.3),float3(0.1,0.4,0.5),dot(uv,float2(0.2,0.7))); //Background
                float3 circleColour = float3(0.9, 0.5, 0.5);
                float3 returnCol = float3(0.0,0.0,0.0);

                for (int i = 0; i < 20; i++) 
                {
                    float seed = float(i);
                    float radius = 0.4 * pow(2,sin(24.0*seed)); // hash(seed * float(i) * 546 + 0.5);
                    float2 randomPos = float2(-2.0 + hash(seed + 1.0)*4.0 ,-1.0);
                    float d = sdCircle(uv,randomPos,radius);
                    returnCol += lerp(backgroundColor/20,circleColour/10,1 - smoothstep(0.0,0.1,d));
                }

                return float4(returnCol,1.0);

            }

            ENDCG
        }
    }
}