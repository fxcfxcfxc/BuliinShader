Shader "Unlit/fxclambert"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        [Normal] _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        [Normal] _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

    }
    
    CGINCLUDE
        #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile LIGHTMAP_ON
            #pragma multi_compile SHADOWS_SHADOWMASK
            #pragma vertex vert
            #pragma fragment frag



            #include "UnityLightingCommon.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
    #include "UnityCG.cginc"
    #include "UnityStandardInput.cginc"
    #include "UnityMetaPass.cginc"
    #include "UnityStandardCore.cginc"

            struct a2f
            {

                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv :TEXCOORD0;
                float2 uv1 :TEXCOORD1;
 

            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 lightUV : TEXCOORD1;
                float3 nDirWS:TEXCOORD2;
                LIGHTING_COORDS(4,5)


            };



            v2f vert (a2f v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                o.nDirWS =UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                o.lightUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
               

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 nDir = i.nDirWS;
                float3 lDir =_WorldSpaceLightPos0.xyz;
                float3 lambert = max(0.0,dot(nDir,lDir));
                float3 bakeLightmapCol =0;
                //bakeLightmapCol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.lightUV));
                return float4(bakeLightmapCol,1);
            }
            ENDCG
        }
        
        UsePass "Standard/META"
    }

}
