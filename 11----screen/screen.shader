Shader "Unlit/screen"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "gray" {}
        _Opacity("透明度",range(0.0,1.0))=0.5
        _OpacityTex("第二张透明贴图",2D)="white"{}

    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"//设置该shader渲染序列
            "RenderType"="TransparentCutout" 
            "ForceNoShadowCasting"="True"
            "IgnoreProject"="True"       
        }
     

        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}
            Blend One OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target3.0
            //相当于Direct3D 9的Shader Model 3.0

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Opacity;
            uniform sampler2D _OpacityTex;
            uniform float4 _OpacityTex_ST;
            


            struct a2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 screenUV :TEXCOORD1;

            };


            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 posVS = UnityObjectToViewPos(v.vertex).xyz;
                float originDist = UnityObjectToViewPos(float3(0.0,0.0,0.0)).z;//获取模型原点在观察空间的位置
                o.screenUV =posVS.xy/posVS.z;
                o.screenUV *=originDist;
                o.screenUV =o.screenUV * _OpacityTex_ST.xy -frac(_Time.x*_OpacityTex_ST.zw);



                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 var_MainTex = tex2D(_MainTex,i.uv);
                half3 finalcolor = var_MainTex.rgb;
                half mask = tex2D(_OpacityTex,i.screenUV);


                half Opacity=var_MainTex.a * _Opacity * mask;
                return half4(finalcolor*Opacity,Opacity);
            }
            ENDCG
        }
    }
}
