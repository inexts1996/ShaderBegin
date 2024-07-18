Shader "UnityShadersBook/Chapter6/BlinnPhongUseBuildInFunction"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(8.0, 256)) = 20
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

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 

                return o;
            }

            fixed4 frag (Varyings i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldViewDir + worldLightDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
