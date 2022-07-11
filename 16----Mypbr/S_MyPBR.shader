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
        //=========================================包含库
        CGINCLUDE
        
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"


        //=======================================自定义函数
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

        float3 PBR(float3 pos, float3 normal, float3 albedo, float rough, float metal, float ao, float shadow)
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

            /*
            #if defined(LIGHTMAP_ON)
                #if defined(SHADOWS_SHADOWMASK)
                //return indirectLight2;
                    return (directLightResult + indirectLight2 ) * shadow + indirectLight;
                #endif
            #endif
            
             */
            return directLightResult * shadow + indirectLight2;

            
        }

        ENDCG
  
        
        
        //===================================pass 0 =================================
        Pass
        {   
            
            //-------------------------------设置pass tags
            Tags 
            { 
                "RenderType" = "Opaque" 
                "LightMode" = "ForwardBase"
            }
            
            
            CGPROGRAM
            
            #pragma multi_compile_fwdbase_fullshadows
            #pragma vertex vert
            #pragma fragment frag



            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float4 _Color;
            sampler2D _RoughnessTex,_MetalTex,_NormalTex;
            float _Roughness,_Metal,_NormalStrength;
            //float _NormalInvertG;
            //float _RoughnessInvert;
            sampler2D _AoTex;



            
  
            //------------------------verticesOut ——》 vertex IN
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent :TANGENT;
            };



            //---------------------vertexOut -> fragmentIn
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWS : TEXCOORD1;
                float3 normalWS: TEXCOORD2;
                float4 tangentWS: TEXCOORD3;
                LIGHTING_COORDS(5,6)
            };
            

            //---------------vertex
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.uv,_MainTex);
                o.posWS = mul(unity_ObjectToWorld,v.vertex);
                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.tangentWS = float4(UnityObjectToWorldDir(v.tangent.xyz),v.tangent.w);
                //根据该pass处理的光源类型（ spot 或 point 或 directional ）来计算光源坐标的具体值
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            
            //---------------fragment
            fixed4 frag (v2f i) : SV_Target
            {
                //数据准备
                float3 normalWS = normalize(i.normalWS);
                //unity_WorldTransformParams?
                float3 binormalWS = cross(i.normalWS,i.tangentWS.xyz) * (i.tangentWS.w * unity_WorldTransformParams.w);

                float3 albedo = tex2D(_MainTex,i.uv) * _Color;
                float roughness = tex2D(_RoughnessTex,i.uv) * _Roughness;
                float metal = tex2D(_MetalTex,i.uv) * _Metal;
                float ao = tex2D(_AoTex,i.uv);

                float shadowAtten = LIGHT_ATTENUATION(i);
                
                float3 pbrCol = PBR(i.posWS,normalWS,albedo,roughness,metal,ao,shadowAtten);
                


                
                return float4(pbrCol,1);
            }
            ENDCG
            
            
            
            
            
        }

        

        //-----shadow PASS
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
