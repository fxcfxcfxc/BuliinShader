Shader "Unlit/Brightness"
{
    Properties
    {
        _MainTex("Base (RGB)",2d) ="white"{}
        _Brightness("Brightness",Float)=1
        _Saturation("Saturation",Float)=1
        _Contrast("Contrast",Float)=1
        

    }
    SubShader
    {

        Pass
        {
            ZTest Always Cull Off  ZWrite off
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half _Brightness,_Saturation,_Contrast;
            

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD0;

            };



            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }


            //片段着色器
            fixed4 frag (v2f i) : SV_Target
            {   
                fixed4 renderTex = tex2D(_MainTex,i.uv);

                //Apply Brightness
                fixed3 finalColor = renderTex.rgb * _Brightness;

                //Apply saturation

                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Saturation);

                //Apply contrast
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);

                return fixed4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }

    fallback"Diffuse"
}
