Shader "Unlit/fxc/frame"
{
    Properties
    {
        
        
        _Color("颜色",Color)=(1,1,1,1)
        _MainTexture("MainTexture",2D)="white"{}
        
        
    }

    SubShader
    {
        
        //====================sub tag设置======================================
        Tags
        {   
            
            //渲染类型
            "RendrType" = "Opaque"
            //渲染排序
            "Queue" = "Geometry"
            
        }
        
        
        //=========================================多pass公用输入数据===================
        CGINCLUDE
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
        ENDCG
        
        //=========================================pass ===================
        
        Pass
        {
                
            Name  "MainPass"
            Tags
            {   
                
                //渲染路径
                " LightMode" = "ForwardBase"
                
            }
            zwrite on
            cull back
            
            CGPROGRAM
            //定义顶点着色器函数 vert
            #pragma vertex vert
            //定义片段着色器函数 frag
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            

            //------------声明
            fixed4 _Color;

            //-----------------纹理申明
            
            uniform sampler2D  _MainTexture;
            


            //-------------------------------- vertciesArrayOut ——》 vertexShaderIn
            struct a2f
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv0: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                float4 tangent:TANGENT;
                float4 color:COLOR;
                
                
            };
            
            
            // ----------------------------------vertexShaderOut  ——》 fragmentShaderIn


            struct v2f
            {
                float4  pos:SV_POSITION;
                float2  uv0:TEXCOORD0;
                float2  uv1:TEXCOORD1;
                float3  nDirWS:TEXCOORD2;
                float3  tDirWS:TEXCOORD3;
                float4  color:TEXCOORD4;
                float4  posWS:TEXCOORD5;
                
            };

            //------------------------------vertexShader
            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.uv0 = v.uv0;
                o.uv1 = v.uv1;
                o.color = v.color;
                o.tDirWS = normalize( mul( unity_ObjectToWorld,float4(v.tangent.xyz, 0.0) ) );
                return o;
            }



            
            //---------------------------fragmentShader
            float4 frag(v2f i):SV_Target
            {
                //--------------------------------准备基本数据
                //主要平行光方向
                float3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);
                //主要平行光方向颜色
                float3 lightColor = _LightColor0.rgb;
                //ambient color
                float3 ambient =  UNITY_LIGHTMODEL_AMBIENT.rgb;
                //片元位置 world space
                float3 posWS = i.posWS.xyz;
                //屏幕UV【0，1】
                float2 ScreenUV = i.pos.xy/ _ScreenParams.xy;
                //Z深度 ndc 空间[-1,1]
                float zdepth = i.pos.w;
                //片元顶点色
                float4 vertexColor = i.color;
                //法线方向 世界
                float3 nDirWS =  normalize( i.nDirWS);
                //切线方向 世界
                float3 tDirWS = i.tDirWS;
                //副切线方向 世界
                float3 biDirWS = normalize( cross(i.nDirWS,i.tDirWS) );
                //UV0
                float2 uv0 = i.uv0;
                //UV1
                float2 uv1= i.uv1;
                // 相机方向  世界
                float3 vDirWS = normalize( (_WorldSpaceCameraPos.xyz - i.posWS) );
                //灯光反射向量 世界
                float3 rDirWS = normalize( reflect(-lDirWS,nDirWS) );
                //影子
                //float shadow = LIGHT_ATTENUATION(i);


                //------------------------------------计算--------------------------
           
                
                float3 fragmentOut = 1 ;
                return float4(fragmentOut,1);
            }
            ENDCG
        }

    }

    fallback"Diffuse"


}