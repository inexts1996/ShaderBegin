Shader "UnityShadersBook/Chapter7/NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            fixed3 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed3 _Specular;
            float _Gloss;

            Varyings vert (a2v v)
            {
                Varyings o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 binormal = cross(normalize( v.normal), normalize( v.tangent)) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (Varyings i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                
               fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
               /* 
                fixed3 tangentNormal;
                tangentNormal.xy = (packedNormal.xy * 2.0-1) * _BumpScale;
                tangentNormal.z = sqrt(1.0-saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                */

                 fixed3 tangentNormal = UnpackNormal(packedNormal);
                 tangentNormal.xy *= _BumpScale;
                 tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = albedo.rgb * _LightColor0.rgb * saturate(dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);

               return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
