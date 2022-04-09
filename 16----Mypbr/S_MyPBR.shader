Shader "PBR/FXCPBR"
{
    Properties
    {
        
        _MainTex("texture",2D)="white"{}
        _Color("Color",Color)=(1,1,1,1)
        
        _RoughnessTex("RoughnessTex",2D)="white"{}
        _Roughness("Roughness",range(0.0,1.0))=0.1
        
        _MetalTex("MetalTex",2D)="white"{}
        [Gamma]_Metal("Metal",Range(0,1))=1.0
        
        _NormalTex("NormaTex",2d)="bump"{}
        
        _AoTex("AOTex",2D)="white"{}
        
        


    }
    SubShader
    {
        //--------公用数据(路径 函数)
        CGINCLUDE
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

        float NDF(float nDoth ,float rough)
        {
            float a = rough * rough;
            float a2 = a * a;
          
            float nDoth2 = nDoth * nDoth;

      
            float denom = (nDoth2 * (a2-1)+1);
            denom = UNITY_PI * denom * denom;

            return a2/denom;
            
        }

        float GeometrySchlickGGX(float nDotv,float rough)
        {
            float r = (rough +1.0);
            float k = (r* r)/8.0;
            float num = nDotv;
            float denom = nDotv * (1.0-k)+k;
            return  num/denom;
            
            
        }

        float GeometrySmith(float nDotv ,float nDotl,  float rough)
        {
  
            float ggx1 = GeometrySchlickGGX(nDotv,rough);
            float ggx2 = GeometrySchlickGGX(nDotl,rough);
            return ggx1 * ggx2;
            
       
        }

        float3 Fresnel(float nDotv,float3 F0)
        {
                return lerp(F0, 1, pow(1-nDotv,5));
            
        }

        float3 PBR(float3 pos, float3 normal, float3 albedo, float rough, float metal, float ao, float shadow, float3 indirectLight)
        {

            //-------------数据准备
            float3 vDir = normalize(_WorldSpaceCameraPos - pos);
            float3 lDir = UnityWorldSpaceLightDir(pos);
       
            float3 hDir = normalize(vDir + lDir);
            float nDotl = saturate(dot(normal,lDir));
            float nDoth = saturate(dot(normal,hDir));
            float nDotv = saturate(dot(normal,vDir));

      

            ////-------------------------------直接光照-----------------------
            float3 F0 = 0.04;//基础反射率
            F0 = lerp(F0, albedo, metal);
            
            //DFG
            float D = NDF(nDoth,rough);
            float G = GeometrySmith(nDotv,nDotl,rough);
            float3 F = Fresnel(nDotv,F0);

            //修复反射闪烁问题
            D=min(D,100);
            
            //计算漫反射比例系数
            float3 kd = 1 -F;
            kd *= 1-metal;

            //计算直接光漫反射和镜面反射
            float3 specular = (D * G * F)/(4 * nDotv * nDotl + 0.00001);
            float3 diffuse = kd * albedo/UNITY_PI;

            float3 directLightResult = (diffuse + specular) * _LightColor0 * nDotl;

            ////--------------------------------间接光照 环境光--------------------------

            //-----间接光 漫反射
            float3 irradiance = ShadeSH9(float4(normal,1));
            float3 diffuseEnvCol = irradiance * albedo;
            
            //-----间接光 镜面反射
            //用视线方向的反射向量 去取样，同时考虑mip层级
            half surfaceReduction=1.0/(rough*rough+1.0);
            float4 color_cubemap = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,reflect(-vDir , normal), 6* rough);
            //使用decodeHDR 将颜色从hdr编码下解码，可以看到采样出的rgbm是一个4通道的值
            float3 specularEnvCol = DecodeHDR(color_cubemap,unity_SpecCube0_HDR);
            specularEnvCol *= F * surfaceReduction;
            float3 indirectLight2 = (kd * diffuseEnvCol + specularEnvCol) * ao;

            
            #if defined(LIGHTMAP_ON)
                #if defined(SHADOWS_SHADOWMASK)
                //return indirectLight2;
                    return (directLightResult + indirectLight2 ) * shadow + indirectLight;
                #endif
            #endif

            return directLightResult * shadow + indirectLight2;
            
            
        }

        ENDCG
        
        

  
            //--------------------shadow

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        
        
                        
        Pass  
        {  
            Name "Meta"
            Tags {"LightMode" = "Meta"}
            Cull Off
         
            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta
         
            #include "Lighting.cginc"
            #include "UnityMetaPass.cginc"
         
            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD1;
                float3 worldPos:TEXCOORD0;
            };
         
            uniform fixed4 _Color;
            uniform sampler2D _MainTex;
            v2f vert_meta(appdata_full v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.pos = UnityMetaVertexPosition(v.vertex,v.texcoord1.xy,v.texcoord2.xy,unity_LightmapST,unity_DynamicLightmapST);
                o.uv = v.texcoord.xy;
                return o;
            }
         
            fixed4 frag_meta(v2f IN):SV_Target
            {
                 UnityMetaInput metaIN;
                 UNITY_INITIALIZE_OUTPUT(UnityMetaInput,metaIN);
                 metaIN.Albedo = tex2D(_MainTex,IN.uv).rgb * _Color.rgb;
                 metaIN.Emission = 0;
                 return UnityMetaFragment(metaIN);
            }
         
            ENDCG
        }
   

    }
}
