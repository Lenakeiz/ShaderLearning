// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/RadialColor"
{   
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            struct v2f {
                float4 position : SV_POSITION;
            };
 
            v2f vert(float4 v:POSITION) : SV_POSITION{
                v2f o;
                o.position = UnityObjectToClipPos(v);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = 0.5 + 0.5 * (i.position.xy - _ScreenParams.xy) / _ScreenParams.xy;
                

                float tau = 3.1415926535*2.0;
                float a = atan2(p.x, p.y);
                float r = length(p)*1.5;
                float2 uv = float2(a / tau, r);
 
                //get the color
                float xCol = (uv.x + (_Time.y / 3.0)) * 3.0;
                xCol = fmod(xCol, 3.0);
                float3 horColour = float3(0.25, 0.25, 0.25);
 
                if (xCol < 1.0) {
 
                    horColour.r += 1.0 - xCol;
                    horColour.g += xCol;
                }
                else if (xCol < 2.0) {
 
                    xCol -= 1.0;
                    horColour.g += 1.0 - xCol;
                    horColour.b += xCol;
                }
                else {
 
                    xCol -= 2.0;
                    horColour.b += 1.0 - xCol;
                    horColour.r += xCol;
                }
 
                // draw color beam
                //uv = (2.0 * uv) - 1.0;
                //float beamWidth = (0.7 + 0.5*cos(uv.x*10.0*tau*0.15*clamp(floor(5.0 + 10.0*cos(_Time.y)), 0.0, 10.0))) * abs(1.0 / (30.0 *(1 - uv.y))); //ORIGINAL
                float beamWidth = (0.7 + 0.5 * cos(uv.x * 10.0 * tau * 0.15 * clamp(floor(5.0 + 10.0 * cos(90)), 0.0, 10.0))) * abs(1.0 / (30.0 * (1 - uv.y)));
                float3 horBeam = float3(beamWidth, beamWidth, beamWidth);
                return float4(( horColour * horBeam), 1.0);
                ////////////////////                
            }
            ENDCG
        }
    }
}