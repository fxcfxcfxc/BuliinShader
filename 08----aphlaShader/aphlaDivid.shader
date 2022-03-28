Shader "Unlit/aphladiveid"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "gray" {}
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"//设置该shader渲染序列
            "RenderType"="TransparentCutout"//渲染类型
            "ForceNoShadowCasting"="True"//关闭阴影投射
            "IgnoreProject"="True"//不响应投射器       
        }
     

        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target3.0
            //相当于Direct3D 9的Shader Model 3.0

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            struct a2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv0 : TEXCOORD0;
                float4 pos : SV_POSITION;
            };


            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 var_MainTex = tex2D(_MainTex,i.uv0);
                half3 color = var_MainTex* var_MainTex.a;//预先乘以aphla

                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
    FallBack"Diffuse"
}
