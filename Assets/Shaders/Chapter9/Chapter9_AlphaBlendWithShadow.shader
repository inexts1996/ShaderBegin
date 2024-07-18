Shader "UnityShadersBook/Chapter9/AlphaBlendWithShadow"
{
    Properties
    {
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            half4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _AlphaScale;

            Varyings vert (a2v v)
            {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o);

                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                half4 texColor = tex2D(_MainTex, i.uv);
                half3 albedo = texColor.rgb * _Color.rgb;
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

                UNITY_LIGHT_ATTENUATION(atten, i,i.worldPos);

                return half4(ambient + diffuse * atten, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    } Fallback "VertexLit"
}
