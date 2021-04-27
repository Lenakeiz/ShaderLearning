Shader "Custom/MobileWaterShader"
{
    Properties
    {
        [HDR] _Color ("Base Color", Color) = (1,1,1,1)
        [HDR] _ShoreLineColor("Shoreline Color", Color) = (1,1,1,1)
        [HDR] _DeepColor("Deep Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5

        _ShoreLine("Shoreline Threshold", float) = 1
        _DeepThreshold("Deep Threshold", float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:premul

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 4.0

        sampler2D _MainTex;
        sampler2D _CameraDepthTexture;

        struct Input
        {
            float3 viewDir;
            float4 screenPos;
        };

        half _Glossiness;
        fixed4 _Color;
        float4 _ShoreLineColor;
        float4 _DeepColor;

        float _ShoreLine;
        float _DeepThreshold;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {

            float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
            
            float shoreline;
            float deepwater;
            float diff;

            if(unity_OrthoParams.w == 0) //Using perspective camera
            {
                depth = LinearEyeDepth(depth);
                diff = depth - IN.screenPos.w;
                shoreline = saturate(diff / _ShoreLine);
                deepwater = saturate(diff / _DeepThreshold);
            }
            else
            {
                float near = _ProjectionParams.y;
                float far = _ProjectionParams.z;
                #ifdef UNITY_REVERSED_Z
                float dist = -lerp(near,far,depth);
                float scrDist = -lerp(near,far, IN.screenPos.z);
                #else
                float dist = -lerp(far,near,depth);
                float scrDist = -lerp(far,near, IN.screenPos.z);
                #endif
                diff = dist - scrDist;
            }
            
            shoreline = saturate(diff / _ShoreLine);
            deepwater = saturate(diff / _DeepThreshold);

            float4 c = lerp(lerp(_ShoreLineColor,_Color, shoreline),_DeepColor,deepwater);
            o.Albedo = c.rgb;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
