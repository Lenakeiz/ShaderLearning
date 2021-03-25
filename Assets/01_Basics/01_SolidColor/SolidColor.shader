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

				///This is breakdown of the MVP matrix (Matrix View Projection)
				//Matrix set the vertex from the model reference to the world reference
				//View set the vertex from the world reference to the camera reference (think the camera as the origin of your reference system). Also called camera space
				//Projection matrix place the object according to the distance of the camera. It is used adjust the model inside the view frustum.
				//All of this is automatically done by UnityObjectToClipPos included in UnityCG.cginc
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
				//The simplest shader. Colot the pixels with the information from the vertex. 
				pixelOutput po;
				po.pixel = o.color;
				return po;
			} 

			ENDCG
		}
		
	}
	Fallback "Mobile/VertexLit"
}