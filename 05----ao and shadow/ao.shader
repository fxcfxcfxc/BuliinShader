Shader "fxc/ao"
{


    Properties
    {
        _AoMap("环境光遮蔽贴图",2D)="white"{}
        _EnvUpColor("朝上环境色",color)=(1.0,1.0,1.0,1.0)
        _EnvMidColor("中部环境色",color)=(0.5,0.5,0.5,1.0)
        _EnvDownColor("朝下环境色",color)=(0.0,0.0,0.0,1.0)

    }
    SubShader
    {   
        Tags{"RenderType"="Opaque"}

        pass
        {


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            uniform float3 _EnvUpColor;
            uniform float3 _EnvMidColor;
            uniform float3 _EnvDownColor;
            uniform sampler2D _AoMap;




            struct a2f{ 
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv0:TEXCOORD0;


            };

            struct v2f{
                float4 pos:SV_POSITION;
                float3 nDirWS :TEXCOORD0;
                float2 uv :TEXCOORD1;

            };

            v2f vert(a2f v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                o.uv=v.uv0;
                return o;

            }


            fixed4 frag(v2f i) :COLOR
            {
                float3 nDir=i.nDirWS;

                float upMask=max(0.0,nDir.g);
                float downMask=max(0.0,-nDir.g);
                float midMask=1-upMask-downMask;
                float3 envcolor = _EnvUpColor*upMask+_EnvMidColor*midMask+_EnvDownColor*downMask;

                float occlusion = tex2D(_AoMap,i.uv);

                float3 finalcolor = envcolor*occlusion;


                return fixed4(finalcolor,1);


            }

            ENDCG

        }
    }

    Fallback "Diffuse"


}

