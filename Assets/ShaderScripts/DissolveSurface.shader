Shader "SpecialEffects/DissolveSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		//Adding a texture to generate the dissolving effect
		_DissolveTexture("Dissolve Texture", 2D) = "white" {}
		//Adding an amount that will be passed from the C# script to generate the dissolve over time
		_Amount("Amount", Range(0.0,1.0)) = 0.15

		_HighlightSize("Highlight Size", float) = 0.5
		_HighlightTexture("Highlight Texture", 2D) = "white" {}
		_HighlightColor("Highlight Color", Color) = (1,1,1,1)
		_HighlightStrength("Highlight Strength", float) = 2.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// This is critical for the shader dissolve and the shadow will follow the 
		#pragma surface surf Lambert addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		
		sampler2D _DissolveTexture;
		float _Amount;
		
		float _HighlightSize;
		float4 _HighlightColor;
		sampler2D _HighlightTexture;
		float _HighlightStrength;

		struct Input {
			float2 uv_MainTex;
			float2 uv_DissolveTexture;
		};

		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutput o) {

			//Using the mask to create clip the 
			half dissolve = tex2D(_DissolveTexture,IN.uv_DissolveTexture).rgb;
			clip(dissolve - _Amount);

			if(_Amount > 0){

				if(dissolve - _Amount < _HighlightSize){
					o.Emission = tex2D(_HighlightTexture, float2( dissolve,0.0)) * _HighlightColor * _HighlightStrength;
				}

				
			}
			
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
