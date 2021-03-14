Shader "Custom/SolidColor"
{
	Properties
	{
		_Color("MainColor", Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vertexShader
			#pragma fragment fragmentShader

			fixed4 _Color;

			//VERTEX INPUT

			struct vertexInput
			{
				float4 vertex : POSITION;
			};

			//VERTEX OUTPUT

			struct vertexOutput
			{
				float4 vertex : SV_POSITION;
				float4 color : Color;
			};

			//VERTEX Shader
			vertexOutput vertexShader(vertexInput i)
			{
				vertexOutput o;
				//o.vertex = UnityObjectToClipPos(i.vertex);

				float x = i.vertex.x;
				float y = i.vertex.y;
				float z = i.vertex.z;
				float w = 1.0;

				i.vertex = float4(x,y,z,w);

				o.vertex = mul(unity_ObjectToWorld, i.vertex);
				o.vertex = mul(UNITY_MATRIX_V, o.vertex);
				o.vertex = mul(UNITY_MATRIX_P, o.vertex);
				o.color = _Color;
				return o;
			}

			//Fragment Shader
			struct pixelOutput
			{
				fixed4 pixel : SV_TARGET;
			};

			pixelOutput fragmentShader (vertexOutput o) : SV_TARGET
			{ 
				pixelOutput po;
				po.pixel = o.color;
				return po;
			} 

			ENDCG
		}
		
	}
	Fallback "Mobile/VertexLit"
}