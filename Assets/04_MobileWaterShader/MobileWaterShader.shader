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
        _Glossiness ("Smoothness", Range(0,4000)) = 0.5
        _SpecularBoost("Specular Boost", float) = 1.0
        [Space(10)]
        _FresnelPower("Fresnel Power", float) = 1.0
        [Space(10)]
        [Normal] _ReflectionDisplacement("Reflection Displacement", 2D) = "white"{}
        _ReflectionDisplacementSpeedX("Reflection Displacement Speed X", float) = 0
        _ReflectionDisplacementSpeedY("Reflection Displacement Speed Ys", float) = 0
        _ReflectionDisplacementPower("Reflection Displacement Power", float) = 1.0
        [Space(10)]
        _CausticTexture("Caustic Texture", 2D) = "black"{}
        _ParallaxRange("Parallax Range", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 200

        GrabPass
        {
            "_GrabPassTexture"
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:premul

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 4.0

        sampler2D _CameraDepthTexture;
        sampler2D _ReflectionDisplacement;
        sampler2D _GrabPassTexture;
        sampler2D _CausticTexture;
        float4 _CausticTexture_ST;

        struct Input
        {
            float3 viewDir;
            float4 screenPos;
            float3 worldPos;
            float2 uv_ReflectionDisplacement;
            float4 grabPassUV;
            float3 viewDirTangent;
            float2 uv_CausticTexture;
        };

        half _Glossiness;
        float _SpecularBoost;
        fixed4 _Color;
        float4 _ShoreLineColor;

        float _ShoreLineThreshold;
        float _FoamThreshold;
        float _FoamSpeed;
        float _FoamLines;

        float _FresnelPower;
        float _ReflectionDisplacementPower;
        float _ReflectionDisplacementSpeedX;
        float _ReflectionDisplacementSpeedY;

        float _ParallaxRange;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float3 BoxProjection(float3 direction, float3 position, float3 cubemapPosition, float3 boxMin, float3 boxMax)
        {
            float3 factors = ((direction > 0 ? boxMax : boxMin))/direction;
            float scalar   = min(min(factors.x,factors.y),factors.z);
            return direction * scalar + (position - cubemapPosition);
        }

        float specular(float3 lightDir, float3 normal, float3 viewDir, float specularPower)
        {
            //float3 halfDir = normalize(viewDir + lightDir);
            //float nDotV = pow(max(0,dot(normal, halfDir)),specularPower);
            //return nDotV;
            float3 R = normalize(2 * dot(normal, -lightDir) * normal + lightDir);
            float s = pow(saturate(dot(R, normalize(-viewDir))), specularPower);
            return s;
        }

        float smin(float a, float b, float t)
        {
            float res = exp2(-t*a) + exp2(-t*b);
            return -log2(res)/t;
        }

        // Need to find a random3 function for the shader and smin
        // float voronoise(float3 uv)
        // {
        //     float3 iuv = floor(uv);
        //     float3 fuv = frac(uv);
        //     float smdist = 1;
        //     float mdist = 1;
        //     for(int y = -1; y<=1; y++)
        //     {
        //         for(int x = -1; x<=1; x++)
        //         {
        //             for(int z = -1; z<=1; z++)
        //             {
        //                 float3 neighbor = float3(float(x),float(y),float(z));
        //                 float3 p = random3(iuv + neighbor);
        //                 float3 diff = neighbor + p - fuv;
        //                 float dist = Length(diff);
        //                 smdist = smin(smdist, dist, 16.0);
        //                 mdist = min(mdist,dist);
        //             }
        //         }
        //     }
        //     return mdist - smdist;
        // }

        //To add the vertex function on the surface shader you have to add the command vertex:vert 
        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input,o);            
            o.grabPassUV = ComputeGrabScreenPos(UnityObjectToClipPos(v.vertex));

            float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
            float3 viewDir = v.vertex.xyz - objCam.xyz;
            float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            float3 bitangent = cross(v.normal.xyz,v.tangent.xyz) * tangentSign;
            o.viewDirTangent = float3(dot(viewDir, v.tangent.xyz),dot(viewDir, bitangent.xyz),dot(viewDir, v.normal.xyz));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {

            float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
            
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
            
            float4 reflNormal       = tex2D(_ReflectionDisplacement, IN.uv_ReflectionDisplacement + float2(_ReflectionDisplacementSpeedX, _ReflectionDisplacementSpeedY) * _Time.y);
            float2 reflDisplacement = (reflNormal * 2.0 - 1.0).rb    * _ReflectionDisplacementPower;
            float3 displacementVec  = float3(reflDisplacement.x,  0.0, reflDisplacement.y);
            
            float fresnel           = 1.0 - saturate(pow(dot(normalize(IN.viewDir),o.Normal),_FresnelPower));

            float4 grabPassCol      = tex2Dproj(_GrabPassTexture, IN.grabPassUV + float4(reflDisplacement, 0.0, 0.0));
            
            float3 worldViewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float3 worldRefl    = reflect(-worldViewDir, o.Normal) + displacementVec;

            float3 reflectedBox = BoxProjection(worldRefl, IN.worldPos, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
            float3 groundCoords = ((_WorldSpaceCameraPos - IN.worldPos) / IN.screenPos.w) * depth - _WorldSpaceCameraPos;

            float4 skyData      = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectedBox);
            float3 skyColor     = DecodeHDR(skyData, unity_SpecCube0_HDR);

            float spec          = specular(_WorldSpaceLightPos0, o.Normal , IN.viewDir + displacementVec, _Glossiness);    
            float caustics      = tex2D(_CausticTexture, groundCoords.xz * _CausticTexture_ST.xy + _CausticTexture_ST.zw);

            float4 c = lerp(_ShoreLineColor,_Color, shoreline);
            //Fresnel is applied before the foam so not to affect the latest
            c.a *= max(0.5,fresnel);
            c += foam;
            float alpha = saturate(c.a);
            o.Albedo = lerp(grabPassCol.rgb, c.rgb, alpha);
            o.Emission = skyColor * fresnel + caustics * smoothstep(3.0, 0.0, diff);
            o.Smoothness = 0.0;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
