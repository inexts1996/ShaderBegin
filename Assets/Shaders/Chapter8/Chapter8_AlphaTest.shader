Shader "UnityShadersBook/Chapter8/AlphaTest"
{
      Properties  {
            _Color  ("Main  Tint",  Color)  =  (1,1,1,1)
            _MainTex  ("Main  Tex",  2D)  =  "white"  {}
            _Cutoff  ("Alpha  Cutoff",  Range(0,  1))  =  0.5
        }
    SubShader
    {
        tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
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
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            Varyings vert (a2v v)
            {
                Varyings o;

                o.pos = UnityObjectToClipPos(v.vertex);
               
               o.worldNormal = UnityObjectToWorldNormal(v.normal);
               o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
               o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (Varyings i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                clip(texColor.a -_Cutoff);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldNormal, worldLightDir));

                return fixed4(ambient + diffuse, 1);
            }
            ENDCG
        }
    } Fallback "Transparent/Cutout/VertexLit"
}
