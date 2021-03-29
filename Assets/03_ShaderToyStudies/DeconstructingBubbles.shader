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

            float sdCircle( float2 p, float2 offset, float r ) 
            {
                return length(p-offset)-r;
            }

            float4 frag(v2f i) : SV_Target {
                
                //This is an attempt to write a single circle on the screen
                float2 uv = (2.0 * i.position.xy - _ScreenParams.xy)/_ScreenParams.y;//We map the coordinate from 0 to 1

                float2 center = float2(0.5,0.5);
                float radius = 0.5;
                
                float3 backgroundColor = float3(0.7,0.7,0.7);
                float3 circleColour = float3(0.9, 0.5, 0.5);
                float d = sdCircle(uv,float2(-0.0,0.0),0.2);

                float3 col = lerp(backgroundColor,circleColour,1 - smoothstep(0.0,0.01,d));

                return float4(col,1.0);

            }

            ENDCG
        }
    }
}