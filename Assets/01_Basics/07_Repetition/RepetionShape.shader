Shader "Custom/RepetionShape"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
		_BorderColor ("Border Color", Color) = (1,1,1,1)
		_CutOut ("Quad cutout", Range (0.0, 0.5)) = 0.1
		_Repetition("Repeat", Range(0,1)) = 0
		_Multiplier("Multipler", Range(1,5)) = 1
		_PivotX("Pivot x", Range(0,1)) = 0.5
		_PivotY("Pivot y", Range(0,1)) = 0.5
		_SpeedMultiplier("Rotation multiplier",Range(0,20)) = 1
		_Blur("Blur", Range(0.001,1)) = 0.003
		_Arrows ("Arrows to draw", Range (0, 3)) = 2
		[KeywordEnum(On,Off)] _UseBlur ("Use Blur", float) = 0

    }
    SubShader
    {

		Tags{"RenderType" = "Opaque"}
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _USEBLUR_ON _USEBLUR_OFF
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

			float4 _Color;
			float4 _BorderColor;
			float _CutOut;
			float _Repetition;
			int _Multiplier;
			float _PivotX;
			float _PivotY;
			float _SpeedMultiplier;
			float _Blur;
			float _Arrows;

			float lerpT1 = 0;
			float lerpT2 = 0;
			float lerpT3 = 0;

			float2 rotate(float2 uv)
			{
				float2 pivot = float2(_PivotX,_PivotY);

				float cosAngle = cos(_Time.y * _SpeedMultiplier);
				float sinAngle = sin(_Time.y * _SpeedMultiplier);

				float2x2 rotM = float2x2 (cosAngle, -sinAngle, sinAngle, cosAngle);
				
				float2 uvpiv = uv - pivot;

				return mul(rotM,uvpiv);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = rotate(v.uv);
                o.uv = v.uv;
                return o;
            }

			float quadshape(float u, float v)
			{
				float left = step(_CutOut,u);
				float right = step(_CutOut,1-u);

				float bottom = step (_CutOut,v);
				float up = step(_CutOut,1-v);

				return left * bottom * right * up;
			}

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

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv; //(i.position.xy / _ScreenParams.xy);
				uv -= .5;
				//uv.x *= _ScreenParams.x/_ScreenParams.y;
				float3 col = float3(0.,0.,0.);
				
				float mask = 0.;
				uv = uv + float2(0.035, -0.01);
				uv = uv/0.6;

				_Arrows = sin(_Time.y * _SpeedMultiplier)*4;

				#if _USEBLUR_ON
					lerpT1 += abs(sin(_Time.y));
					lerpT2 += abs(sin(_Time.y));
					lerpT3 += abs(sin(_Time.y));
				#else
					lerpT1 = 1.0;
					lerpT2 = 1.0;
					lerpT3 = 1.0;
				#endif

				if(_Arrows > 2.)
				{					
					mask += Rect(uv, -.35, .07, -.045, .045, max(lerp(0.5,0.0001,lerpT1),0.0001) );
					mask += Rect(uv, -.45+uv.y, -.33+uv.y, .0, .26,max(lerp(0.5,0.0001,lerpT1),0.0001) );
					mask += Rect(uv, -.45-uv.y, -.33-uv.y, -.26, .0, max(lerp(0.5,0.0001,lerpT1),0.0001));
				}

				if(_Arrows > 1.)
				{
					mask += Rect(uv, .02+uv.y*0.56, .115+uv.y*0.56, -.045, .35, max(lerp(0.5,0.0001,lerpT2),0.0001));
					mask += Rect(uv, -.24+uv.y*0.6, .06+uv.y*.6, .27+uv.x*0.25, .365+uv.x*0.25, max(lerp(0.5,0.0001,lerpT2),0.0001));
					mask += Rect(uv, .36-uv.y*0.3, .46-uv.y*0.3, -.62+uv.x*1.7, -.104+uv.x*1.7, max(lerp(0.5,0.0001,lerpT2),0.0001));
				}

				if(_Arrows > 0.)
				{
					mask += Rect(uv, .02-uv.y*0.56, .115-uv.y*0.56, -.35, .0, max(lerp(0.5,0.0001,lerpT3),0.0001));
					mask += Rect(uv, .02-uv.y*0.56, .115-uv.y*0.56, -.35, .0, max(lerp(0.5,0.0001,lerpT3),0.0001));
					mask += Rect(uv, .35+uv.y*0.25, .44+uv.y*0.25, -.365-uv.x*0.27, 0.55-uv.x*1.5,max(lerp(0.5,0.0001,lerpT3),0.0001));
					mask += Rect(uv, -.21-uv.y*0.5, .1-uv.y*0.5, -.36-uv.x*0.29, -.27-uv.x*0.28, max(lerp(0.5,0.0001,lerpT3),0.0001)); 
				}



				col = float3(1., 1., 1.)*mask;
               
                return float4(col,1.0);
            }

			//This has been created for the previous post
			//fixed4 frag (v2f i) : SV_Target
            //{
			//	i.uv = i.uv * _Multiplier - _Repetition;
			//	fixed4 col = fixed4(0,0,0,1.0);
            //    float shape = quadshape(frac(i.uv.x), frac(i.uv.y));
			//	shape = abs(1-shape);
            //    col = _Color * shape;
			//	col += _BorderColor * (1-shape);
            //    return col;
            //}
            ENDCG
        }
    }
}
