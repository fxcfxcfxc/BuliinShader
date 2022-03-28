Shader "Unlit/fxc/outline"
{
    Properties
    {
        _OutlineColor("颜色",Color)=(0,0,0,1)
        _OutlineRange("描边大小",float)=0.1

        
    }

    SubShader
    {
        pass
        {

            cull Front
            ZWrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _OutlineColor;
            float _OutlineRange;

            struct a2f
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;

            };

            v2f vert(a2f v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                float2 pnormal_xy =mul((float2x2)UNITY_MATRIX_P,vnormal.xy);
                o.pos.xy = o.pos.xy +pnormal_xy*_OutlineRange;
                return o;
   
            }
            fixed4 frag(v2f i):SV_TARGET
            {
                return _OutlineColor;
            }


            ENDCG
        }

        Pass
        {

            CGPROGRAM
            //定义顶点着色器函数 vert
            #pragma vertex vert
            //定义片段着色器函数 frag
            #pragma fragment frag

            fixed4 _Color;

            //用来做顶点着色器的传入
            struct a2f
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD;

            };
 
            //顶点着色器的输出变量，用来做片段着色器的传入
            struct v2f
            {

                float4 pos:SV_POSITION;// 定义pos的值为顶点在裁切空间的位置信息
                float2 uv:TEXCOORD;
            };

            //顶点函数
            v2f vert(a2f v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //片段函数
            fixed4 frag(v2f i):SV_TARGET
            {
                return fixed4(i.uv,0,1);

            }

            ENDCG

        }




    }







}