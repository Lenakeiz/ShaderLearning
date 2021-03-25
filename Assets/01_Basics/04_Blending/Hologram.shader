Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Hologram("Hologram", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Frequency("Frequency",Range(0,2)) = 1
        _Speed("Sweep speed", float) = 1
        _AlphaCutOff("Transparency CutOff",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { 
                "RenderType"="Opaque"
                "Queue" = "Transparent"
             }

        //ZWrite Off
        Blend SrcAlpha One // Traditional transparency
        //Blend One OneMinusSrcAlpha // Premultiplied transparency
        //Blend One One // Additive
        //Blend OneMinusDstColor One // Soft Additive
        //Blend DstColor Zero // Multiplicative
        //Blend DstColor SrcColor // 2x Multiplicative

        BlendOp Add     
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
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 hologram_uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Hologram;
            float4 _Hologram_ST;
            float4 _Color;
            float _Frequency;
            float _AlphaCutOff;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.hologram_uv = (v.uv * _Hologram_ST.xy + _Hologram_ST.zw);
                //Moving the uv over time
                o.hologram_uv.y += _Time * _Speed;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                fixed4 holo = tex2D(_Hologram, i.hologram_uv);
                col = holo + col;
                //Adding some motion to the color
                col.a = abs(sin(i.hologram_uv.y * _Frequency));
                col.a = max(col.a, _AlphaCutOff);
                return col;
            }
            ENDCG
        }
    }
}
