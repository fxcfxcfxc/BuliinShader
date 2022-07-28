Shader "DAM/Reflection/PlaneMirrorReflection"
{
    Properties
    {
        [Header(_____________________________Texture)]
        _OffsetTexture("扰动贴图",2D)="black"{}
        _MainTex("RT（自动生成）",2D) = "white"{}
        
        
        [space]
        [Header(_____________________________BaseAdjust)]
        _offsetStrength("扭曲强度",Range(0,1)) = 0.08
        _BlurSize("Blursize",Range(0,0.1) )= 0.05
        _MipMapLevel("模糊等级",Range(0,6)) =0.0
  
    }    
        
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            uniform sampler2D _OffsetTexture;
            uniform float _offsetStrength,_BlurSize;
            half4 _MainTex_TexelSize;
            uniform float  _MipMapLevel;
            
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 UV0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 UV0 : TEXCOORD1;
                float4 UVarray[5] :TEXCOORD2;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                
                // 返回的是 clip space 空间下的 屏幕坐标  【0，w】
                float4 projUV = ComputeGrabScreenPos(o.vertex);
                
                // //拿到周围的坐标
                o.UVarray[0] = projUV;
                o.UVarray[1] = projUV + float4(_MainTex_TexelSize.x * 1.0, 0.0, 0.0, 0.0) * _BlurSize;
                o.UVarray[2] = projUV - float4(_MainTex_TexelSize.x * 1.0, 0.0, 0.0, 0.0) * _BlurSize;
                o.UVarray[3] = projUV + float4(_MainTex_TexelSize.x * 2.0, 0.0, 0.0, 0.0) * _BlurSize;
                o.UVarray[4] = projUV - float4(_MainTex_TexelSize.x * 2.0, 0.0, 0.0, 0.0) * _BlurSize;
    
                o.UV0 = v.UV0;
                
                
                return o;

                
            }

            float4 frag (v2f i) : SV_Target
            {
                //---------------------------------------------------------------方式一
                //扰动UV偏移
                // float2 offsetUV =( tex2D(_OffsetTexture,i.UV0)*2) -1;
                //
                //
                // float weight[3] = {0.4026, 0.2442, 0.0545};

                //X轴方向
                // float3 reflectCol = tex2Dproj(_MainTex, i.UVarray[0]+ float4(offsetUV * _offsetStrength,0,0)) * weight[0];
                // reflectCol += tex2Dproj(_MainTex, i.UVarray[1] + float4(offsetUV * _offsetStrength,0,0))* weight[1];
                // reflectCol += tex2Dproj(_MainTex, i.UVarray[2] + float4(offsetUV * _offsetStrength,0,0))* weight[1];
                // reflectCol += tex2Dproj(_MainTex, i.UVarray[3] + float4(offsetUV * _offsetStrength,0,0))* weight[2];
                // reflectCol += tex2Dproj(_MainTex, i.UVarray[4] + float4(offsetUV * _offsetStrength,0,0))* weight[2];

 
                // return float4(reflectCol.xyz,1.0);
                //

                //----------------------------------------------------------------方式二 平均模糊

                //扭曲
                // float2 offsetUV =tex2D(_OffsetTexture,i.UV0) *2 -1;
                // float2 posScreenUV = i.vertex.xy / _ScreenParams.xy;
                // posScreenUV += offsetUV *_offsetStrength;
                // float3 reflectCol = tex2D(_MainTex, posScreenUV );
                // 
                //
                // float3 reflectCol2 = tex2D(_MainTex, posScreenUV  + float2(_BlurSize,_BlurSize));
                // float3 reflectCol3 = tex2D(_MainTex, posScreenUV  - float2(_BlurSize,_BlurSize));
                //
                //
                // return float4( (reflectCol+reflectCol2 +reflectCol3)/3 , 1.0);
                //

                
                //-----------------------------------------------------------方式三
                // float2 offsetUV = tex2D(_OffsetTexture,i.UV0) *2 -1;
                // float2 posScreenUV = i.vertex.xy / _ScreenParams.xy;
                // posScreenUV += offsetUV *_offsetStrength;
                //
                // float  dx = ddx( posScreenUV) * 10;
                // float2 dsdx = float2(dx,dx);
                //
                // half4 reflectCol = tex2D(_MainTex, posScreenUV, dsdx, float2(0.0, 0.0) );
                //
                // return reflectCol;



                //----------------------------------------------------------方式四 mipmaps
                float2 offsetUV = tex2D(_OffsetTexture,i.UV0) *2 -1;
                float2 posScreenUV = i.vertex.xy / _ScreenParams.xy;
                posScreenUV += offsetUV *_offsetStrength;
                
                half4 reflectCol0 = tex2Dlod(_MainTex, float4( posScreenUV, 0 , _MipMapLevel) );
                // half4 reflectCol1 = tex2Dlod(_MainTex, float4( posScreenUV, 0 , 1) );
                // half4 reflectCol2 = tex2Dlod(_MainTex, float4( posScreenUV, 0 , 2) );
                // half4 reflectCol3 = tex2Dlod(_MainTex, float4( posScreenUV, 0 , 3) );
                // half4 reflectCol4 = tex2Dlod(_MainTex, float4( posScreenUV, 0 , 4) );
    
            
    
                // if( 0.0 < _MipMapLevel < 1.0)
                // {
                //     reflectCol = lerp(reflectCol0, reflectCol1, _MipMapLevel);
                // }
                
                //
                // if(1.0 < _MipMapLevel <= 2.0)
                // {
                //
                //     reflectCol = lerp(reflectCol1, reflectCol2, _MipMapLevel-1.0);
                // }
                //
                // if(_MipMapLevel == 0.0)
                // {
                //      reflectCol = reflectCol0;
                // }
                //


                
                return float4(reflectCol0.rgb,1);
                
                //

                
            }

            
            ENDCG
        }
    }
}

