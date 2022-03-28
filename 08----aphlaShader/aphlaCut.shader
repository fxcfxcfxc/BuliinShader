Shader "Unlit/aphlacut"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "gray" {}
        _Cutoff("透切阈值",range(0.0,2.0))=0.5
    }
    SubShader
    {
        Tags { 
            "RenderType"="TransparentCutout"//
            "ForceNoShadowCasting"="True"//关闭阴影投射
            "IgnoreProject"="True"//不响应投射器      
        }

        Pass
        {
            Cull off//背面渲染
            Name "ForWARD"
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target3.0
            //相当于Direct3D 9的Shader Model 3.0

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform half _Cutoff;

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
                clip(var_MainTex.a - _Cutoff);//clip内的值小于0 则对片元舍弃

                return var_MainTex;
            }
            ENDCG
        }
    }
}
