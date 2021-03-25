Shader "Custom/TextureUV"
{

    Properties
    {
        _MainTex("Texture", 2D) = "white"{}
        _Color("Tint", Color) = (1,1,1,1)
    }

    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            
            #include "UnityCG.cginc"

            uniform sampler2D _MainTex; //This is used to connect our properties from inside the shader
            uniform float4 _MainTex_ST; //By adding this semantics we can control for the offset and tiling
            uniform float4 _Color;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; //TEXCOORD1, TEXTCOORD2, upt to 9 I think (?)
            };

            struct vertexOutput
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            vertexOutput vertexShader(vertexInput i)
            {
                vertexOutput o;
                o.position = UnityObjectToClipPos(i.vertex);
                // We can just pass the texture coordinate to the fragment shader. In this way we cannot use the tiling or the offset.
                o.uv = i.uv;

                // The following are the same (the second one is short hand form using UnityCG.cginc)
                // To scale the coordinateswe can multiply them for value. Notice that multiplication/addition is component wise 
                o.uv = (i.uv * _MainTex_ST.xy + _MainTex_ST.zw);

                //o.uv = TRANSFORM_TEX(i.uv, _MainTex);
                return o;
            }

            fixed4 fragmentShader(vertexOutput o) : SV_TARGET
            {
                //We sample the texture
                fixed4 col = tex2D(_MainTex,o.uv) * _Color;
                return col;
            }

            ENDCG
        }
        
    }

}