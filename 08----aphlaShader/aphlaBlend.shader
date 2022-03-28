Shader "Unlit/aphlablent"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "gray" {}
        _Opacity("透明度",range(0.0,1.0))=0.5
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"//设置该shader渲染序列排序
            "RenderType"="Transparent"//渲染类型 
            "ForceNoShadowCasting"="True"//关闭投影
            "IgnoreProject"="True"//不响应投射器       
        }
     

        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}

            Blend One OneMinusSrcAlpha//混合方式

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


            struct a2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };


            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 var_MainTex = tex2D(_MainTex,i.uv);
                half3 finalcolor = var_MainTex.rgb;
                half Opacity=var_MainTex.a * _Opacity;
                return half4(finalcolor*Opacity,Opacity);
            }
            ENDCG
        }
    }
}
