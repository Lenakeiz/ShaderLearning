Shader "Custom/MobileWaterShader"
{
    Properties
    {
        [HDR]_Color ("Base Color", Color) = (1,1,1,1)
        [HDR]_ShoreLineColor("Shoreline Color", Color) = (1,1,1,1)
        _ShoreLineThreshold("Shoreline Threshold", float) = 1
        [Space(10)]
        _FoamThreshold("Foam Threshold", float) = 1
        _FoamSpeed("Foam Speed", float) = 1
        _FoamLines("FoamLines", Range(1,5)) = 3
        [Space(10)]
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        [Space(10)]
        _FresnelPower("Fresnel Power", float) = 1.0
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

        sampler2D _CameraDepthTexture;

        struct Input
        {
            float3 viewDir;
            float4 screenPos;
            float3 NORMAL;
        };

        half _Glossiness;
        fixed4 _Color;
        float4 _ShoreLineColor;

        float _ShoreLineThreshold;
        float _FoamThreshold;
        float _FoamSpeed;
        float _FoamLines;

        float _FresnelPower;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {

            float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)).r;
            
            //Saturate is being used to lerp between the colors
            float shoreline;
            float foam;
            //Keeps the information of the distance betweeen the depth buffer value in world scaled view space and the current position in the z buffer of the vertex point
            //Since the shader is transparent it does not write to the zbuffer but the projection is mantained in the w coordinate
            float diff; 

            if(unity_OrthoParams.w == 0) 
            {
                //Using perspective camera
                depth = LinearEyeDepth(depth);
                diff = depth - IN.screenPos.w;
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
            
            shoreline = saturate(diff / _ShoreLineThreshold);
            foam      = saturate(diff / _FoamThreshold);
            //Last step is to keep the the foam out from the intersection
            //First step is to ensure you get sharp edges for the foam wave and not a gradient towards zero
            foam = saturate(step(0.7,(sin(((1.0 - foam) + _Time.y * _FoamSpeed) * UNITY_TWO_PI * _FoamLines) * 0.5 + 0.5) * (1.0 - foam)) + step(0.95, 1.0 - foam)); 
            
            float fresnel = 1.0 - saturate(pow(dot(normalize(IN.viewDir),o.Normal),_FresnelPower)); 
            
            float4 c = lerp(_ShoreLineColor,_Color, shoreline);
            //Fresnel is applied before the foam so not to affect the latest
            c *= fresnel;
            c += foam;
            
            o.Albedo = c.rgb;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
