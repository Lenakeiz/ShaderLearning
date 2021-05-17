Shader "Custom/PaperLantern"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

		[HDR]_EmissionColor ("Color", Color) = (0.000000,0.000000,0.000000,1.000000)
		[NoScaleOffset]_EmissionMap ("Emission", 2D) = "white" { }

        _NoiseTex("Noise Texture", 2D) = "white" {}
        _Height("Dissolve Height", Float) = 1
        _DissolveColor("Dissolve color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Interpolation("Dissolve Interpolation", Range(0,10)) = 1
    }

    CGINCLUDE
    //@TODO: should this be pulled into a shader_feature, to be able to turn it off?
    #define _GLOSSYENV 1
    #define UNITY_SETUP_BRDF_INPUT SpecularSetup
    ENDCG

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        Cull Off


        CGPROGRAM
        #include "UnityPBSLighting.cginc"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard addShadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;
        sampler2D _EmissionMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        float4 _Color;
        float4 _EmissionColor;
        float4 _DissolveColor;
        float _Interpolation;
        float _Height;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {

            float l = (IN.worldPos.y - _Height);
			clip(  (l + (tex2D(_NoiseTex, IN.uv_NoiseTex) * _Interpolation)) );

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            
            o.Albedo = c.rgb;
            //o.Normal = normal * 2.0;
            // Metallic and smoothness come from slider variables
            o.Metallic   = _Metallic;
            o.Smoothness = _Glossiness;
            o.Emission   = lerp(_EmissionColor, saturate(l) *_DissolveColor.rgb * tex2D(_NoiseTex, IN.uv_NoiseTex), smoothstep(1.0-_Interpolation, 0.1, saturate(l)));
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
