// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "UnityShadersBook/Chapter9/ForwardRendering"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 255)) = 20
    }
    SubShader
    {

        Pass
        {
            tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings 
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            Varyings vert (a2v v)
            {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Varyings i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldToViewPos(i.worldPos));
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                half atten = 1.0;
                return fixed4((ambient + diffuse + specular) * atten, 1);
            }
            ENDCG
        }
        
        Pass
        {
            tags {"LightMode"="ForwardAdd"}

            Blend One One

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            Varyings vert (a2v v)
            {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Varyings i) : SV_Target
            {

                #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                #ifdef USING_DIRECTIONAL_LIGHT
                half atten = 1.0;
                #else
                #if defined(POINT)
                float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                half atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #elif defined(SPOT)
                float4 lightCoord = mul(unity_worldToLight, float4(i.worldPos, 1));
                fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #else
                fixed atten = 1.0;
                #endif
                #endif

                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldToViewPos(i.worldPos));
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                return fixed4((diffuse + specular) * atten, 1);
            }
            ENDCG
        }
    }
   Fallback "Specular"
}
