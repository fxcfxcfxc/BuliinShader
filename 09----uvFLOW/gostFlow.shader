Shader "Unlit/gostFlow"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "gray" {}
        _MainColor("颜色倾向",color)=(1.0,1.0,1.0,1.0)
        _Opacity("透明度",range(0.0,1.0))=0.5
        _WarpTex("扭曲图",2D)="gray"{}
        _WrapInt("扭曲强度",range(0.0,1.0))=0.5
        _NoiseInt("噪波强度",range(0.0,5.0))=0.5
        _FlowSpeed("流动速度",range(0,20))=5
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"//设置该shader渲染序列
            "RenderType"="Transparent" 
            "ForceNoShadowCasting"="True"//关闭阴影投射
            "IgnoreProject"="True"//不响应投射器      
        }
     

        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}
            Blend SrcAlpha OneMinusSrcAlpha//混合模式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            //#pragma target3.0
            //相当于Direct3D 9的Shader Model 3.0

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Opacity;
            uniform sampler2D _WarpTex;
            uniform float4 _WarpTex_ST;
            uniform float _WrapInt;
            uniform float _NoiseInt;
            uniform float _FlowSpeed;
            uniform float3 _MainColor; 


            struct a2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv0 : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uv1 : TEXCOORD1;
            };


            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.uv, _WarpTex);
                o.uv1.y =o.uv1.y+frac(-_Time.x*_FlowSpeed);//获取新的UV动画坐标

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 var_WarpTex = tex2D(_WarpTex,i.uv1).rgb;//采样噪波图
                float2 uvBias =(var_WarpTex-0.5)*_WrapInt;//reamp噪波图，RG通道
                float2 uv0 =i.uv0+ uvBias;//得到干扰后的UV坐标

                half4 var_MainTex =tex2D(_MainTex,uv0);//采样颜色贴图
                half3 finalcolor = var_MainTex.rgb*_MainColor;//叠加倾向色

                half noise = lerp(1.0,var_WarpTex.b *2.0,_NoiseInt);
                noise = max(0.0,noise);
                half opacity = var_MainTex.a * _Opacity* noise;

                //return half4(var_MainTex);
                return half4(finalcolor,opacity);
            }
            ENDCG
        }
    }
}
