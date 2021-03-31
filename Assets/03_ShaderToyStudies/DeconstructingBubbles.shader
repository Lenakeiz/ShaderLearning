// This is a study I have been doing to port simpler shadertoy to unity. Most of them are based on image effects and needs to be placed on the camera.
// The script to add the image effects to the camera are in the same folder of this shader.
// For this effect I have been looking at the following shader to take inspirations
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

            void rotateUV( inout float2 p, float a ) 
            {
	            p = cos( a ) * p + sin( a ) * float2( p.y, -p.x );
            }

            //Experimenting with different random noises
            float hash(float p)
            {
	            // Return a "random" number based on the "seed"
                return frac(sin(p) * 43758.5453);
            }
            //Same as before but take a vector as input
            float hashSine12(float2 p)
            {
                // Two typical hashes...
	            return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            float hash11(float p)
            {
                p = frac(p * .1031);
                p *= p + 33.33;
                p *= p + p;
                return frac(p);
            }

            float2 hash22(float2 p)
            {
	            float3 p3 = frac(float3(p.xyx) * float3(.1031, .1030, .0973));
                p3 += dot(p3, p3.yzx+33.33);
                return frac((p3.xx+p3.yz)*p3.zy);
            }

            float sdCircle( float2 p, float2 offset, float r ) 
            {
                return length(p-offset)-r;
            }
            
            float4 frag(v2f i) : SV_Target {
                
                //This is an attempt to write a single circle on the screen
                float2 uv = (2.0 * i.position.xy - _ScreenParams.xy)/_ScreenParams.y;//We map the coordinate from 0 to 1

                float3 backgroundColor = lerp(float3(0.3,0.2,0.9),float3(0.3,0.3,0.2),1 - dot(uv,float2(0.8,0.8))); //Background
                float3 circleColour = float3(1.0, 0.1, 0.0);
                float3 returnCol = float3(0.0,0.0,0.0);
                float time = _Time.y;

                int Nballs = 30;
                for (int i = 0; i < Nballs; i++) 
                {
                    rotateUV(uv,1.2 + time * 0.01);
                    float seed = float(i);
                    //It s very useful to use https://www.desmos.com/ to look function graphs
                    float radius = 0.15 * pow(2,sin(24.0*seed)); // hash(seed * float(i) * 546 + 0.5);
                    float2 randomPos = float2(-2.0 + hash11(seed + 1.0)*4.0 ,-1.0 + hash11(seed*542356 + 1.0)*2.0);
                    float d = sdCircle(uv,randomPos,radius);
                    //Hashing the colour to create some movement effects on the shader
                    float3 currCircleColour = float3(circleColour.x - hash11(seed + time * 0.001) + 0.05,circleColour.y,circleColour.z);
                    //Need to normalize otherwise the background colour will saturate quickly
                    //Inigo instead of adding subtracts the colour before inverting the xyz of the current one. I am not sure what that operation should mean so I ll go my way.
                    returnCol += lerp(backgroundColor/Nballs,currCircleColour,1 - smoothstep(0.0,0.025,d));
                }

                return float4(returnCol,1.0);

            }

            ENDCG
        }
    }
}