Shader "UnityShadersBook/Chapter11/Water"
{
    Properties
    {
        _MainTex ("Main  Tex", 2D) = "white" {}
        _Color ("Color  Tint", Color) = (1, 1, 1, 1)
        _Magnitude ("Distortion  Magnitude", Float) = 1
        _Frequency ("Distortion  Frequency", Float) = 1
        _InvWaveLength ("Distortion  Inverse  Wave  Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" "DisableBatching"="True"
        }

        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UpdatePerMaterial)
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                float4 _MainTex_ST;
                float4 _Color;
                float _Magnitude;
                float _Frequency;
                float _InvWaveLength;
                float _Speed;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float4 offset;
                offset.yzw = float3(0.0, 0.0, 0.0);
                offset.x = sin(_Frequency * _Time.y + IN.positionOS.x * _InvWaveLength + IN.positionOS.y * _InvWaveLength + IN.positionOS.z * _InvWaveLength) * _Magnitude;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv.xy = TRANSFORM_TEX(IN.texcoord, _MainTex);
                OUT.uv += float2(0.0, _Time.y * _Speed);

                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
               float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                color.rgb *= _Color.rgb;
                return color;
            }
            ENDHLSL
        }
    }
}