Shader "Unlit/normal"
{
    Properties
    {
        _NormalMap("normalmap",2D)="bump"{}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {

            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            uniform sampler2D _NormalMap;
            uniform float4 _MainTex_ST;

            struct a2f
            {

                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv0:TEXCOORD0;
                float4 tangent :TANGENT;
 

            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv0:TEXCOORD0;
                float3 nDirWS:TEXCOORD1;//法线向量
                float3 tDirWS:TEXCOORD2;//切线向量
                float3 bDirWS:TEXCOORD3;//副切线向量



            };



            v2f vert (a2f v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);//顶点在裁切空间下的位置
                o.uv0 =v.uv0;
                o.nDirWS =UnityObjectToWorldNormal(v.normal);
                o.tDirWS =normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.bDirWS =normalize(cross(o.nDirWS,o.tDirWS) * v.tangent.w);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 nDirTS =UnpackNormal(tex2D(_NormalMap,i.uv0));
                float3x3 TBN = float3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                float3 nDir =normalize(mul(nDirTS,TBN));

                float3 lDir =_WorldSpaceLightPos0.xyz;
                float lambert = max(0.0,dot(nDir,lDir));

                return float4(lambert,lambert,lambert,1);
            }
            ENDCG
        }
    }

    fallback"Diffuse"
}
