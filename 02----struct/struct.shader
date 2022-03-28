Shader "Unlit/fxc/struct"
{
    Properties
    {
        _Color("颜色",Color)=(1,1,1,1)

        
    }

    SubShader
    {

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