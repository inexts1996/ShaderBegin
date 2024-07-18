Shader "UnityShadersBook/Chapter10/Mirror"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode"="forwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Varyings vert(a2v v)
            {
                Varyings o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv = 1 - o.uv;
                
                return o;
            }

            fixed4 frag(Varyings i) : SV_Target
            {
                return  tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}