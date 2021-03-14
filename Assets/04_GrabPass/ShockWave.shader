// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Shockwave"
{
	Properties
	{
		_Annulus ("Annulus Radius", Float) = 1 // An annulus is the 2D version of a Torus. This is the inside radius, in local coordinates
		_MaxRange ("Outer Radius", Float) = 1 //outer radius, in local coordinates
		_DistortionStrength ("DistortionStrength", Float) = 1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "PreviewType"="Plane"}
		LOD 100

		GrabPass { "_GrabTexture"}

		Pass
		{
			ZWrite Off
			Blend One Zero
			Lighting Off
			Fog { Mode Off }
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
				float4 uv : TEXCOORD0; //our fragment position as a uv-coordinate of the grab-pass texture
				float4 uv_center : TEXCOORD1; //the position of our object center on the grab-pass texture
				float4 vertex : SV_POSITION;
				float4 obj_vertex : TEXCOORD2; //our fragment position in local object space
			};

			sampler2D _GrabTexture;
			half _Annulus;
			half _MaxRange;
			half _DistortionStrength;
		
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = ComputeGrabScreenPos(o.vertex);
				o.obj_vertex = v.vertex;
				o.uv_center = ComputeGrabScreenPos(UnityObjectToClipPos(float4(0., 0., 0, 1)));
				return o;
			}
		
			fixed4 frag (v2f i) : COLOR
			{
				half dist = length(i.obj_vertex.xy);
				dist = saturate((dist - _MaxRange + _Annulus) / (_Annulus)); //interpolation value with zero as the inside edge of the annulus and 1 as the outside edge

				if(dist > 0 && dist < 1)
				{
					dist = dist * dist; //nonlinear distribution, so it's not just magnifying stuff. Also makes the transition smooth on the inside of the annulus, but sharp on the outside
					float2 projUv = i.uv.xy / i.uv.w;
					float2 projUvCenter = i.uv_center.xy /i.uv_center.w;
					return tex2D(_GrabTexture, projUv + dist * _DistortionStrength * normalize(projUv - projUvCenter)); //our uv, but shifted outwards (in local space)
				}
				else
				{
					return tex2D(_GrabTexture, i.uv); //no distortion
				}
			}
			ENDCG
		}
	}
}