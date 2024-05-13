Shader "UnityShadersBook/Chapter9/ForwardRendering"
{
    Properties
    {
    }
    SubShader
    {

        Pass
        {
            tags {"LightMode""="ForwardBase"}
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct a2v
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

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }

        
        Pass
        {
            tags {"LightMode"="ForwardAdd"}

            Blend One One

            HLSLPROGRAM

            #pragma multi_compile_fwdadd
            ENDHLSL
        }
    }
}
