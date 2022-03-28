Shader "Unlit/fxc/Gouraud"
{

    Properties
    {
        _ColorM("颜色",Color)=(1.0,1.0,1.0,1.0)

    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opapue"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            uniform float4 _ColorM;
            uniform float _SpecularPow;

            struct a2f
            {
                float4 vertex :POSITION;
                float4 normal :NORMAL;


            };

            struct v2f
            {
                float4 posCS :SV_POSITION;
                float4 posWS :TEXCOORD0;
                float3 nDirWS :TEXCOORD1;
                float4 color :TEXCOORD2;


            };

            v2f vert(a2f v)
            {
                v2f o;
                o.posCS = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);

                float3 lDir = _WorldSpaceLightPos0.xyz;
                float ndotl = dot(o.nDirWS,lDir);
                
                o.color =_ColorM * ndotl;


                return o;

            }

            fixed4 frag(v2f i) :COLOR
            {

                return float4(i.color);

            }

            ENDCG
        }






    }
    
    Fallback "Diffuse"

}

