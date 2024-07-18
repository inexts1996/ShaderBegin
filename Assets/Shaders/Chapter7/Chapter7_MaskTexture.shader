Shader "UnityShadersBook/Chapter7/MaskTexture"
{
    Properties
    {
            _Color  ("Color  Tint",  Color)  =  (1,1,1,1)
            _MainTex  ("Main  Tex",  2D)  =  "white"  {}
          [NoScaleOffset]  _BumpMap  ("Normal  Map",  2D)  =  "bump"  {}
            _BumpScale("Bump  Scale",  Float)  =  1.0
          [NoScaleOffset]  _SpecularMask  ("Specular  Mask",  2D)  =  "white"  {}
            _SpecularScale  ("Specular  Scale",  Float)  =  1.0
            _Specular  ("Specular",  Color)  =  (1,  1,  1,  1)
            _Gloss  ("Gloss",  Range(8.0,  256))  =  20
    }
    SubShader
    {
        Pass
        {
            tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent  : TANGENT;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;


            Varyings vert (a2v v)
            {
                Varyings o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz; 
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (Varyings i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse  = _LightColor0.rgb * albedo * saturate(dot(tangentLightDir, tangentNormal));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

                fixed3 specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss)* specularMask;

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }Fallback "Specular"
}
