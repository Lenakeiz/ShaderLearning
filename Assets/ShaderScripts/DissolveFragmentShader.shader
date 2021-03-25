// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DissolveFragmentShader"
{
	Properties
	{
		_Color ("Main Color", Color) = (.5,.5,.5,1)

		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Texture", 2D) = "white" {}
        _ToonShade ("ToonShader Cubemap(RGB)", CUBE) = "" { }
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_EdgeColour1 ("Edge colour 1", Color) = (1.0, 1.0, 1.0, 1.0)
		_EdgeColour2 ("Edge colour 2", Color) = (1.0, 1.0, 1.0, 1.0)
		_Level ("Dissolution level", Range (0.0, 1.0)) = 0.1
		_Edges ("Edge width", Range (0.0, 1.0)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
            Name "BASE"
			//Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
            //ZWrite Off
            //Lighting Off
        	//Fog { Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile DUMMY PIXELSNAP_ON
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
			};

			struct v2f
			{
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;				
                float3 cubenormal : TEXCOORD1;
                UNITY_FOG_COORDS(2)

			};

            float4 _Color;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _EdgeColour1;
			float4 _EdgeColour2;
			float _Level;
			float _Edges;
			float4 _MainTex_ST;
            samplerCUBE _ToonShade;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				#ifdef PIXELSNAP_ON
                o.vertex = UnityPixelSnap (o.vertex);
                #endif

                //o.cubenormal = UnityObjectToViewPos(float4(v.normal,0));
                o.cubenormal = mul (UNITY_MATRIX_MV, float4(v.normal,0));
				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float cutout = tex2D(_NoiseTex, i.uv).r;
				fixed4 basecol = _Color * tex2D(_MainTex, i.uv);
                fixed4 cube = texCUBE(_ToonShade, i.cubenormal);
                fixed4 col = fixed4(2.0f * cube.rgb * basecol.rgb, basecol.a);
				UNITY_APPLY_FOG(i.fogCoord, col);
				if (cutout < _Level)
                {
                    discard;
                }

				if(cutout < col.a && cutout < _Level + _Edges)
                {
                    col =lerp(_EdgeColour1, _EdgeColour2, (cutout-_Level)/_Edges );
                }
					
				return col;
			}
			ENDCG
		}
	}
}