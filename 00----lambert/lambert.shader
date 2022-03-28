Shader "Unlit/lambert"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct a2f
            {

                float4 vertex:POSITION;
                float3 normal:NORMAL;
 

            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 nDirWS:TEXCOORD0;


            };



            v2f vert (a2f v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                o.nDirWS =UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 nDir = i.nDirWS;
                float3 lDir =_WorldSpaceLightPos0.xyz;
                float3 lambert = max(0.0,dot(nDir,lDir));

                return float4(lambert,1);
            }
            ENDCG
        }
    }

    fallback"Diffuse"
}
