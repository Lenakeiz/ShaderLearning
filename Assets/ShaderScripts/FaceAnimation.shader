Shader "Custom/FaceAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Base Color",Color) = (1,1,1,1)
		_MovementAmplitude("Movement Amplitude", Range(0,6)) = 1
		_MovementSpeed("MovementSpeed", Range(0,5)) = 1
		_RotationSpeed("RotationSpeed", Range(0,10)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		Cull OFF
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            }; 

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _MovementAmplitude;
			float _MovementSpeed;
			float _RotationSpeed;

		
			// Rotation with angle (in degrees) and axis: from the mythical keijiro
			float4x4 AngleAxis4x4(float angle, float3 axis)
			{
				float cosa, sina;
				sincos(angle, sina, cosa);

				float t = 1 - cosa;
				float x = axis.x;
				float y = axis.y;
				float z = axis.z;

				return float4x4(
				t * x * x + cosa    ,  t * x * y - sina * z,  t * x * z + sina * y, 0.0,
				t * x * y + sina * z,  t * y * y + cosa    ,  t * y * z - sina * x, 0.0,
				t * x * z - sina * y,  t * y * z + sina * x,  t * z * z + cosa    , 0.0,
				0.0                 ,  0.0                 ,  0.0                 ,	1.0
				);
			}

			float4 applyMotionToFaces(float4 vertexPos, float4 normal)
			{
				//Apply translation to each face
				vertexPos += (abs(sin(_Time.y * _MovementSpeed)) * _MovementAmplitude) * normal;
				//Apply rotation to each face
				//Note that hsls has row major column so the order should be Ab where A is matrix
				vertexPos = mul(AngleAxis4x4(_Time.y * _RotationSpeed, normal), vertexPos);

				return UnityObjectToClipPos(vertexPos);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = applyMotionToFaces(v.vertex, v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
