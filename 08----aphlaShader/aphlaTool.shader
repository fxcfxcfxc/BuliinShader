Shader "Unlit/aphlaTool"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "gray" {}
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendSrc("混合源乘子",int)=0
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendDst("混合目标乘子",int)=0
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("混合模式",int)=0
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
            BlendOp[_BlendOp]
            Blend [_BlendSrc][_BlendDst]

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
                return var_MainTex;
            }
            ENDCG
        }
    }
}
