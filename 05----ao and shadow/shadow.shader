Shader "fxc/shadow"
{


    Properties
    {


    }
    SubShader
    {   
        Tags{"RenderType"="Opaque"}

        Pass
        {
            Name  "FORWARD"
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0


            struct a2f{ 
                float4 vertex:POSITION;



            };

            struct v2f{
                float4 pos:SV_POSITION;
                LIGHTING_COORDS(0,1)
      

            };

            v2f vert(a2f v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;

            }


            float4 frag(v2f i):COLOR
            {
                float shadow = LIGHT_ATTENUATION(i);
      

                return float4(shadow,shadow,shadow,1.0);


            }

            ENDCG

        }
    }

    Fallback "Diffuse"//所有shader都不能运行的时候运行这个shader


}

