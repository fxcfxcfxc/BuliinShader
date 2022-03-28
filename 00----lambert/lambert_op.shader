Shader "Unlit/lambert_op"
{
    Properties
    {
        _Op("OP",range(0.0,1.0))=1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  "Queue"="Transparent"}
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha//混合模式
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform float _Op;

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

                return float4(lambert,_Op);
            }
            ENDCG
        }
    }

    fallback"Diffuse"
}
