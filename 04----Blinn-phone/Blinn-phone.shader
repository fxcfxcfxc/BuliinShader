Shader "Unlit/fxc/Blinn_phone"
{

    Properties
    {
        _ColorM("颜色",Color)=(1.0,1.0,1.0,1.0)
        _SpecularPow("高光强度",float)=1

    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opapue"

        }
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            
            
            uniform float3 _ColorM;
            uniform float _SpecularPow;

            struct a2f
            {
                float4 vertex :POSITION;
                float4 normal :NORMAL;
                float2 uv0: TEXCOORD0;


            };

            struct v2f
            {
                float4 pos :SV_POSITION;
                float2 uv:TEXCOORD0;
                float4 posWS :TEXCOORD1;
                float3 nDirWS :TEXCOORD2;
                LIGHTING_COORDS(3,4)//


            };

            v2f vert(a2f v)
            {
                v2f o;
                o.uv = v.uv0;
                o.pos = UnityObjectToClipPos(v.vertex);//注意后面使用了内置函数所以 命名必须是pos
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                TRANSFER_VERTEX_TO_FRAGMENT(o)//投影函数
                return o;

            }
            //法线和半角方向dot blinnphone
            fixed4 frag(v2f i) :COLOR
            {

                float3 nDir = i.nDirWS;
                float3 lDir =_WorldSpaceLightPos0.xyz;
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz-i.posWS);
                float3 hDir =normalize(vDir+lDir);

                float ndotl = dot(nDir,lDir);
                float ndoth = dot(nDir,hDir);

                float lambert = max(0.0,ndotl);
                float blinnphon = pow(max(0.0,ndoth),_SpecularPow);
                float shadow = LIGHT_ATTENUATION(i);//
                float3 finalcolor = _ColorM * lambert + blinnphon;
                finalcolor *= shadow;
                return float4(finalcolor,1.0);

            }

            ENDCG
        }






    }
    
    Fallback "Diffuse"

}

