Shader "Custom/NewUnlitUniversalRenderPipelineShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 0, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _Speed("Rainbow Speed", Float) = 0.3
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float _Speed;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.normal = IN.normal.xyz;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // 法線のx成分 [-1, +1] を [0, 1] に変換して位置 t とする
                float t = normalize(IN.normal).x * 0.5 + 0.5;

                // 時間でずらして、色相 h を 0〜1 でループさせる
                float h = frac(t + _Time.y * _Speed);

                // 色相 -> RGB (ループする虹色)
                float3 rainbow = saturate(
                    abs(frac(h + float3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0);

                return half4(rainbow, 1);
            }
            ENDHLSL
        }
    }
}
