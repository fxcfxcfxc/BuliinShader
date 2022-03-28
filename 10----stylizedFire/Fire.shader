Shader "Unlit/Fire"
{
    Properties
    {
        _FireTex("R:外焰 G：内焰 B：透贴",2D)="blue"{}
        _Noise("R:噪波1 G：噪波2",2D)="gray"{}
        _Noise1Control("x:噪波1纹理大小 Y:流速  Z：强度",vector)=(1.0,0.2,0.2,1.0)
        _Noise2Control("x:噪波2纹理大小 Y:流速  Z：强度",vector)=(1.0,0.2,0.2,1.0)
        [HDR]_FireColor1("火焰外部颜色",Color)=(1.0,1.0,1.0,1.0)
        [HDR]_FireColor2("火焰内部颜色",Color)=(0.5,0.5,0.5,0.5)

        


    }
    SubShader
    {
        Tags {
            "Queue"="Transparent" 
            "RenderType"="Transparent"
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"   
        }

 
        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}//标签枚举
            Blend One OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_complie_fwdBase_fullshadows
            #pragma target3.0

            uniform sampler2D _FireTex;
            uniform sampler2D _Noise;
            uniform half3 _Noise1Control;
            uniform half3 _Noise2Control;
            uniform half3 _FireColor1;
            uniform half3 _FireColor2;



            struct a2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;

            };


            v2f vert (a2f v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv0=v.uv;
                o.uv1 = v.uv*_Noise1Control.x;
                o.uv1.y =o.uv1.y -frac(_Time.x * _Noise1Control.y);//流动强度
                o.uv2 = v.uv*_Noise2Control.x;
                o.uv2.y = o.uv2.y -frac(_Time.x*_Noise2Control.y);//流动强度

                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {

                //扰动uv的mask
                half var_warpMask =tex2D(_FireTex,i.uv0).b;
                //扰动噪波
                half var_Noise1= tex2D(_Noise,i.uv1).r;
                half var_Noise2= tex2D(_Noise,i.uv2).g;
                half warp_Noise = var_Noise1*_Noise1Control.z + var_Noise2*_Noise2Control.z;
                //扰动uv采样
                float2 warpUV = i.uv0;
                warpUV.y=warpUV.y -warp_Noise*var_warpMask;
                //color
                half3 mask = tex2D(_FireTex,warpUV);

                half3 finalcolor = _FireColor1*mask.r + _FireColor2* mask.g;
                half op =mask.r+mask.g;

                return half4(finalcolor,op);
            }
            ENDCG
        }
    }
}
