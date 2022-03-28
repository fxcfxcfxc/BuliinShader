Shader "Unlit/fxc/oldschool"
{

    Properties
    {
        _BaseCol("基本颜色",Color)=(1.0,1.0,1.0,1.0)
        _SpecularPow("高光强度",float)=1
        _AoMap("环境光遮蔽",2D)="white"{}

        _EnvupColor("朝上环境颜色",Color)=(1.0,1.0,1.0,1.0)
        _EnvmidColor("中间环境颜色",Color)=(0.5,0.5,0.5,1.0)
        _EnvdownColor("下面环境颜色",Color)=(0.0,0.0,0.0,1.0)

        _LightCol("高光颜色",Color)=(1.0,1.0,1.0,1.0)
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opapue"
        }
        Pass
        {
            Name  "FXC"
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            //.#pragma vertex vert是一个预处理指令，表明一个以vert为名字的函数的顶点程序
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            
            uniform float3 _BaseCol;
            uniform float _SpecularPow;
            uniform float3 _EnvupColor;
            uniform float3 _EnvmidColor;
            uniform float3 _EnvdownColor;
            uniform sampler2D _AoMap;
            uniform float3 _LightCol;



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
                LIGHTING_COORDS(3,4)
               


            };

            v2f vert(a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv0;
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
    
                TRANSFER_VERTEX_TO_FRAGMENT(o)


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
                float3 baseshader = _BaseCol * lambert + blinnphon;
                float shadow = LIGHT_ATTENUATION(i);

                float upMask = max(0.0,nDir.g);
                float downMask = max(0.0,-nDir.g);
                float midMask = 1 -upMask -downMask;
                float3 envColor=_EnvupColor*upMask + _EnvmidColor*midMask + _EnvdownColor*downMask;


                float aoMap = tex2D(_AoMap,i.uv);

                float3 finalcolor=baseshader*shadow*_LightCol+envColor*aoMap;
                
                return float4(finalcolor,1.0);

            }

            ENDCG
        }






    }
    
    Fallback "Diffuse"

}

