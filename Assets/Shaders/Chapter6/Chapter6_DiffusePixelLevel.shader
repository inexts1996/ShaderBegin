// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShadersBook/Chapter6/DiffusePixelLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                
                #include "Lighting.cginc"

                struct a2v
                {
                    float3 vertex : POSITION;   
                    float3 normal : NORMAL;
                };

                struct Varyings
                {
                    float4 pos : SV_POSITION; 
                    float3 worldNormal : TEXCOORD0;
                };

                fixed4 _Diffuse;

                Varyings vert(a2v v)
                {
                    Varyings o;

                    o.pos = UnityObjectToClipPos(v.vertex); 
                    o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject); 

                    return o;
                }

                fixed4 frag(Varyings i) : SV_Target
                {
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                    fixed3 diffuse =  _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                    fixed3 color = ambient + diffuse;
                   return fixed4(color, 1.0); 
                }
                ENDCG
        }
    }
}
