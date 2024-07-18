Shader "UnityShadersBook/Chapter11/ScrollingBackground"
{
    Properties
    {
        _MainTex ("Base  Layer  (RGB)", 2D) = "white" {}
        _DetailTex ("2nd  Layer  (RGB)", 2D) = "white" {}
        _ScrollX ("Base  layer  Scroll  Speed", Float) = 1.0
        _Scroll2X ("2nd  layer  Scroll  Speed", Float) = 1.0
        _Multiplier ("Layer  Multiplier", Float) = 1
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
                "LightMode"="UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
                TEXTURE2D(_MainTex);
                TEXTURE2D(_DetailTex);
                SAMPLER(sampler_MainTex);
                float4 _MainTex_ST;
                float4 _DetailTex_ST;
                float _ScrollX;
                float _Scroll2X;
                float _Multiplier;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);

                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 firstLayer = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv.xy);
                float4 secondLayer = SAMPLE_TEXTURE2D(_DetailTex, sampler_MainTex, IN.uv.zw);

                float4 color = lerp(firstLayer, secondLayer, secondLayer.a);
                color.rgb *= _Multiplier;

                return color;
            }
            ENDHLSL
        }
    } Fallback "Universal Render Pipeline/Lit"
}