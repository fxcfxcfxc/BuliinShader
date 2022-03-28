Shader "Unlit/fxc/frame"
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
            //顶点着色器
            float4 vert(float4 vertex:POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(vertex);
            }

            //片段着色器
            fixed4 frag():SV_TARGET
            {
                return _Color;

            }

            ENDCG

        }




    }







}