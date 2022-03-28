Shader "Unlit/uvOffset"
{
    Properties
    {
        _MainTex("颜色",2D)="white"{}
        _Speed("时间",float)=1.0
        _xCount("列数",int)=3
        _yCount("行数",int)=3


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

            uniform sampler2D _MainTex;
            uniform float _Speed;
            uniform int _xCount;
            uniform int _yCount;

            struct a2f
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv :TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 nDirWS:TEXCOORD1;
                float2 uv0 :TEXCOORD0;
            };

            v2f vert (a2f v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                o.nDirWS =UnityObjectToWorldNormal(v.normal);
                o.uv0 = v.uv;
                float _Cout =floor((_Time.z *_Speed));//(t/20, t, t*2, t*3)
                float idV =floor(_Cout/_xCount);
                float idU = _Cout-idV*_xCount;
                float stepU =1.0/_xCount;
                float stepV =1.0/_yCount;
                o.uv0 =o.uv0*float2(stepU,stepV)+float2(0.0,(_yCount-1)*stepV);
                o.uv0 = o.uv0+float2(stepU*idU,-stepV*idV);
            
                
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {

                half4 color = tex2D(_MainTex,i.uv0);
                //float3 nDir = i.nDirWS;
                //float3 lDir =_WorldSpaceLightPos0.xyz;
                //float3 lambert = max(0.0,dot(nDir,lDir));
                return color;
            }
            ENDCG
        }
    }

    fallback"Diffuse"
}
