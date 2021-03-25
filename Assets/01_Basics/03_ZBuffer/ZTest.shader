Shader "Custom/ZTest"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTestFirstPass("ZTest first pass", Int) = 4 //"LessEqual"
        //[Enum(UnityEngine.Rendering.CompareFunction)] _ZTestSecondPass("ZTest second pass", Int) = 4 //"LessEqual"

        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            //ZTest decide the order in which the pixel are rendered based on the values written in the zbuffer. Bigger values wins at the same rendering queue.
            ZTest [_ZTestFirstPass]
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        //Pass
        //{
        //    ZTest [_ZTestSecondPass]
        //    CGPROGRAM
        //    #pragma vertex vert
        //    #pragma fragment frag

        //    #include "UnityCG.cginc"

        //    uniform float4 _Color;

        //    struct appdata
        //    {
        //        float4 vertex : POSITION;
        //    };

        //    struct v2f
        //    {
        //        float4 vertex : SV_POSITION;
        //    };

        //    v2f vert (appdata v)
        //    {
        //        v2f o;
        //        o.vertex = UnityObjectToClipPos(v.vertex);
        //        return o;
        //    }

        //    fixed4 frag (v2f i) : SV_Target
        //    {
        //        // sample the texture
        //        fixed4 col = _Color;
        //        return col;
        //    }
        //    ENDCG
        //}

    }
}
