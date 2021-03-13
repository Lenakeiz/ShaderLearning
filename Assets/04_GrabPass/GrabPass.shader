Shader "Custom/GrabPass"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        GrabPass {"_BackgroundTexture"}
        LOD 100

        Pass
        {
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
                float4 uvgrab : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BackgroundTexture;

            v2f vert (appdata v)
            {
                v2f o;
                //Playing around with vertices
                //v.vertex.y = v.vertex.y * abs(sin(_Time.y));
                //v.vertex.x = v.vertex.x * abs(sin(_Time.y));
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex.y = o.vertex.y + 0.2 * sin(_Time.y);
                //Requires the input in the clip space
                o.uvgrab = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Getting rid of the projection
                //i.uvgrab.xyz = i.uvgrab.xyz * i.uvgrab.w;
                //Similar to tex2D by divides the coordinate of the texture by w (to calculate for the projection)
                
                fixed4 col = 1 - tex2Dproj(_BackgroundTexture,i.uvgrab);
                return col;
            }
            ENDCG
        }
    }
}
