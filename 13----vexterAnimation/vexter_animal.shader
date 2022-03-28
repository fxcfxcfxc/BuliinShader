Shader "Unlit/aphlablent"
{
    Properties
    {
        _MainTex("RGB:颜色 A：透贴", 2D) = "white" {}
        _Opacity("透明度",range(0.0,1.0))=0.5
        _moveRange("移动范围",float)=1                                                                    
        _moveSpeed("移动速度",float)=1
        _scaleRange("缩放范围",float)=1
        _scaleSpeed("缩放速度",float)=1
        _roRange("旋转范围",float)=1
        _roSpeed("旋转速度",float)=1

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
            uniform float _moveRange;
            uniform float _moveSpeed;
            uniform float _scaleRange;
            uniform float _scaleSpeed;
            uniform float _roRange;
            uniform float _roSpeed;



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

            void vertexMoveAndScale (inout float3 vertex)
            {   
                vertex.y=vertex.y + sin(frac(_Time.z*_moveSpeed)*6.2)*_moveRange;
                vertex = vertex * sin(frac(_Time.z*_scaleSpeed)*3.1)*_scaleRange;
      
            }
            void vertexRotation(inout float3 vertex)
            {

                   float angle = _roRange*sin(frac(_Time.z*_roSpeed)*6.2);
                   float rad =radians(angle);
                   float sinY,cosY = 0;
                   sincos(rad,sinY,cosY);

                   vertex.xz  =float2(
                       vertex.x * cosY - vertex.z * sinY,
                       vertex.x * sinY + vertex.z * cosY
                         
                   );
      
            
            }


            v2f vert (a2f v)
            {
                v2f o;
                vertexRotation(v.vertex.xyz);
                vertexMoveAndScale(v.vertex.xyz);
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
