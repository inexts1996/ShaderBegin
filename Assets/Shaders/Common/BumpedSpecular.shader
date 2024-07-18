Shader "UnityShadersBook/Common/BumpedSpecular"
{
    Properties
    {
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}
        _Bump("Texture", 2D) = "Bump" {}
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue"="Geometry"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;

                SHADOW_COORDS(4)
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bump;
            float4 _Bump_ST;
            fixed4 _specular;
            float _Gloss;

            Varyings vert(a2v v)
            {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bump);

                TANGENT_SPACE_ROTATION;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(Varyings i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_Bump, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(bump, lightDir));

                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _specular.rgb * pow(dot(bump, halfDir), _Gloss);

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);


                return fixed4(ambient + (diffuse + _specular) * atten, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }
            CGPROGRAM
            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;

                SHADOW_COORDS(4)
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bump;
            float4 _Bump_ST;
            fixed4 _specular;
            float _Gloss;

            Varyings vert(a2v v)
            {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bump);

                TANGENT_SPACE_ROTATION;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(Varyings i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_Bump, i.uv.zw));
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(bump, lightDir));

                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _specular.rgb * pow(dot(bump, halfDir), _Gloss);

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);


                return fixed4((diffuse + _specular) * atten, 1.0);
            }
            ENDCG
        }
    }
}