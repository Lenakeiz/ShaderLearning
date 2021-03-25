Shader "Custom/UnityLogo" {

	Properties
	{
		_Blur("Blur", Range(0,1)) = 0.003
		[KeywordEnum(On, Off)] _ArrowOne ("Display arrow one", float) = 0
	}
    SubShader {
   
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile
			#pragma shader_feature _ArrowOne_ON _ArrowOne_OFF
            struct v2f{
                float4 position : SV_POSITION;
            };
           
            v2f vert(float4 v:POSITION) : SV_POSITION {
                v2f o;
                o.position = UnityObjectToClipPos (v);
                return o;
            }

			float _Blur;

			float Band(float t, float start, float end, float blur){
				float step1 = smoothstep(start-blur, start+blur, t);
				float step2 = smoothstep(end+blur, end-blur, t);
    
				return step1*step2;
			}

			float Rect(float2 uv, float left, float right, float bottom, float top, float blur){
				float band1 = Band(uv.x, left, right, blur);
				float band2 = Band(uv.y, bottom, top, blur);
    
				return band1*band2;
			}

            float4 frag(v2f i) : SV_Target {
           
                float2 uv = (i.position.xy / _ScreenParams.xy);
				uv -= .5;
				//uv.x *= _ScreenParams.x/_ScreenParams.y;
				float3 col = float3(0.,0.,0.);
				
				float mask = 0.;
				uv = uv + float2(0.035, -0.01);
				uv = uv/0.6;

				mask += Rect(uv, -.35, .07, -.045, .045, 0.003);
				mask += Rect(uv, -.45+uv.y, -.33+uv.y, .0, .26, 0.003);
				mask += Rect(uv, -.45-uv.y, -.33-uv.y, -.26, .0, 0.003);

				mask += Rect(uv, -.35, .07, -.045, .045, 0.003);
				mask += Rect(uv, -.45+uv.y, -.33+uv.y, .0, .26, 0.003);
				mask += Rect(uv, -.45-uv.y, -.33-uv.y, -.26, .0, 0.003);
				mask += Rect(uv, .02+uv.y*0.56, .115+uv.y*0.56, -.045, .35, 0.003);
				mask += Rect(uv, .02-uv.y*0.56, .115-uv.y*0.56, -.35, .0, 0.003);
				mask += Rect(uv, .02-uv.y*0.56, .115-uv.y*0.56, -.35, .0, 0.003);
				mask += Rect(uv, -.24+uv.y*0.6, .06+uv.y*.6, .27+uv.x*0.25, .365+uv.x*0.25, 0.003);
				mask += Rect(uv, .36-uv.y*0.3, .46-uv.y*0.3, -.62+uv.x*1.7, -.104+uv.x*1.7, 0.003);
				mask += Rect(uv, .35+uv.y*0.25, .44+uv.y*0.25, -.365-uv.x*0.27, 0.55-uv.x*1.5, 0.003);
				mask += Rect(uv, -.21-uv.y*0.5, .1-uv.y*0.5, -.36-uv.x*0.29, -.27-uv.x*0.28, 0.003); 
                
				col = float3(1., 1., 1.)*mask;
               
                return float4(col,1.0);
            }

            ENDCG
        }
    }
}