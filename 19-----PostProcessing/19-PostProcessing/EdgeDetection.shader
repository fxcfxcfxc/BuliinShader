Shader "Unlit/EdgeDetection"
{
    Properties
    {
        _MainTex("Base (RGB)",2d) ="white"{}
        _EdgeOnly("EdgeOnly",Float)=1.0
        _EdgeColor("EdgeColor",Color)=(0,0,0,1)
        _BackgroundColor("BackgroundColor",Color)=(1,1,1,1)
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
            half4 _MainTex_TexelSize;//xxx_TexelSize 是Unity 为我们提供的访问xxx纹理对应的每个纹素的大小
            fixed _EdgeOnly;
            fixed4 _EdgeColor,_BackgroundColor;

            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }
            
            //顶点-》片段 
            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv[9] : TEXCOORD0;

            };

        
            //顶点着色器
            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
 
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);
                return o;
            }

            half Sobel(v2f i)
            {   
                const half Gx[9]={-1, -2, -1,
                                   0,  0,  0,
                                   1,  2,  1};
                
                const half Gy[9]={-1, 0, 1,
                                  -2, 0, 2,
                                  -1, 0, 1};

                half texColor;
                half edgeX =0;
                half edgeY =0;
                for(int x =0; x<9; x++)
                {
                    texColor = luminance(tex2D(_MainTex,i.uv[x]));
                    edgeX = edgeX + texColor * Gx[x];
                    edgeY = edgeX + texColor * Gy[x];
 
                }

                half edge = 1- abs(edgeX) - abs(edgeY);
                return edge;
            }

            //片段着色器
            fixed4 frag (v2f i) : SV_Target
            {       
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);
                fixed4 finalColor = lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);

 
                
                return finalColor;
            }
            ENDCG
        }
    }

    fallback"Diffuse"
}
