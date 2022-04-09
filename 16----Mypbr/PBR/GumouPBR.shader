Shader "PBR/GumouPBR"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("_Color", Color) = (1,1,1,1)

        [Space][Header(__________ Roughness __________)][Space]
        _RoughnessTex ("_RoughnessTex", 2D) = "white" {}
        _Roughness ("_Roughness", Range(0,1)) = 0
        [Toggle]_RoughnessInvert ("_RoughnessInvert", Int) = 0
        
        [Space][Header(__________ Metallic __________)][Space]
        _MetalTex ("_MetalTex", 2D) = "white" {}
        _Metal ("_Metal", Range(0,1)) = 0

        [Space][Header(__________ Normal __________)][Space]
        [Normal]_NormalTex ("_NormalTex", 2D) = "bump" {}
        _NormalStrength ("_NormalStrength", float) = 1
        [Toggle]_NormalInvertG ("_NormalInvertG", Int) = 0

        [Space][Header(__________ AO __________)][Space]
        _AoTex ("_AoTex", 2D) = "white" {}


    }
    SubShader
    {

        CGINCLUDE
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            float NDF(float NdotH , float rough){
                float a = rough * rough;
                float a2 = a *a ;
                float NdotH2 = NdotH * NdotH;

                float denom = (NdotH2 * (a2 - 1) + 1);
                denom = UNITY_PI * denom * denom;

                return a2/denom;
            }
            float GF(float NdotV,float NdotL,float rough){
                float r = (rough + 1);
                float k = (r*r)/8;
                
                float ggx1 = NdotV /lerp(k,1,NdotV);
                float ggx2 = NdotL /lerp(k,1,NdotL);
                return ggx1 * ggx2;
            }
            float3 Fresnel(float NdotV,float3 F0){
                return lerp(F0,1,pow(1 - NdotV , 5));
            }

            float3 PBR(float3 pos,float3 normal,float3 albedo,float rough,float metal,float ao, float shadow){
                float3 viewDir = normalize(_WorldSpaceCameraPos - pos);
                float3 lightDir = UnityWorldSpaceLightDir(pos);
                float3 halfDir = normalize(normal+lightDir);
                half NdotL = saturate(dot(normal,lightDir));
                half NdotH = saturate(dot(normal,halfDir));
                half NdotV = saturate(dot(normal,viewDir));

                float3 F0 = 0.04;
                F0 = lerp(F0,albedo,metal);

                float D = NDF(NdotH,rough);
                float G = GF(NdotV,NdotL,rough);
                float F = Fresnel(NdotV , F0);
                D = min(D,100);

                float3 kD = 1- F;
                kD *= 1-metal;

                float3 specular = (D * G * F) / (4*NdotV*NdotL + 0.00001);
                float3 diffuse = kD * albedo /UNITY_PI;

                float3 finalCol = (diffuse + specular) * _LightColor0 * NdotL * shadow;

                //env col
                float3 irradiance = ShadeSH9(float4(normal,1));
                float3 diffuseEnvCol = irradiance * albedo;
                float4 color_cubemap = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,reflect(-viewDir , normal), 6* rough);
                float3 specularEnvCol = DecodeHDR(color_cubemap,unity_SpecCube0_HDR);
                specularEnvCol *= F;
                float3 envCol = (kD * diffuseEnvCol + specularEnvCol);
                envCol *= ao;
                
                return finalCol + envCol;
            }

        
            float3 PBR_Direct(float3 pos,float3 normal,float3 albedo,float rough,float metal,float ao, float shadow){
                float3 viewDir = normalize(_WorldSpaceCameraPos - pos);
                float3 lightDir = UnityWorldSpaceLightDir(pos);
                float3 halfDir = normalize(normal+lightDir);
                half NdotL = saturate(dot(normal,lightDir));
                half NdotH = saturate(dot(normal,halfDir));
                half NdotV = saturate(dot(normal,viewDir));

                float3 F0 = 0.04;
                F0 = lerp(F0,albedo,metal);

                float D = NDF(NdotH,rough);
                float G = GF(NdotV,NdotL,rough);
                float F = Fresnel(NdotV , F0);
                D = min(D,100);

                float3 kD = 1- F;
                kD *= 1-metal;

                float3 specular = (D * G * F) / (4*NdotV*NdotL + 0.00001);
                float3 diffuse = kD * albedo /UNITY_PI;

                float3 finalCol = (diffuse + specular) * _LightColor0 * NdotL * shadow;

                return finalCol;
            }

        ENDCG

        Pass
        {
            Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
            CGPROGRAM
            
            #pragma multi_compile_fwdbase_fullshadows
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent :TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNormal: TEXCOORD2;
                float4 worldTangent: TEXCOORD3;
                LIGHTING_COORDS(5,6)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            sampler2D _RoughnessTex,_MetalTex,_NormalTex;
            float _Roughness,_Metal,_NormalStrength;
            float _NormalInvertG;
            float _RoughnessInvert;
            sampler2D _AoTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = float4(UnityObjectToWorldDir(v.tangent), v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 binormal = cross(i.worldNormal,i.worldTangent.xyz) * (i.worldTangent.w * unity_WorldTransformParams.w);
                half4 normal = tex2D(_NormalTex,i.uv);
                normal.g = lerp(normal.g,1-normal.g,_NormalInvertG);
                normal.xyz = UnpackNormalWithScale(normal,_NormalStrength);
                normal.xyz = normal.xzy;
                worldNormal = normalize(
                    normal.x * i.worldTangent + 
                    normal.y * i.worldNormal + 
                    normal.z * binormal
                );
                
                float3 albedo = tex2D(_MainTex,i.uv) * _Color;
                float rough = tex2D(_RoughnessTex, i.uv);
                rough = lerp(rough, 1- rough , _RoughnessInvert);
                rough *= _Roughness;
                float metal = tex2D(_MetalTex,i.uv) * _Metal;
                float ao = tex2D(_AoTex,i.uv);


                float shadowAtten = LIGHT_ATTENUATION(i);
                float3 pbrCol = PBR(i.worldPos,worldNormal,albedo,rough,metal,ao,shadowAtten);


                fixed4 col = tex2D(_MainTex, i.uv);
                col.xyz = pbrCol;
                return col;
            }
            ENDCG
        }


          Pass
        {
            Tags { "RenderType" = "Opaque" "LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            
            #pragma multi_compile_fwdadd_fullshadows
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent :TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNormal: TEXCOORD2;
                float4 worldTangent: TEXCOORD3;
                LIGHTING_COORDS(5,6)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            sampler2D _RoughnessTex,_MetalTex,_NormalTex;
            float _Roughness,_Metal,_NormalStrength;
            float _NormalInvertG;
            float _RoughnessInvert;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = float4(UnityObjectToWorldDir(v.tangent), v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 binormal = cross(i.worldNormal,i.worldTangent.xyz) * (i.worldTangent.w * unity_WorldTransformParams.w);
                half4 normal = tex2D(_NormalTex,i.uv);
                normal.g = lerp(normal.g,1-normal.g,_NormalInvertG);
                normal.xyz = UnpackNormalWithScale(normal,_NormalStrength);
                normal.xyz = normal.xzy;
                worldNormal = normalize(
                    normal.x * i.worldTangent + 
                    normal.y * i.worldNormal + 
                    normal.z * binormal
                );
                
                float3 albedo = tex2D(_MainTex,i.uv) * _Color;
                float rough = tex2D(_RoughnessTex, i.uv) ;
                rough = lerp(rough, 1- rough , _RoughnessInvert);
                rough *= _Roughness;
                float metal = tex2D(_MetalTex,i.uv) * _Metal;


                float shadowAtten = LIGHT_ATTENUATION(i);
                float3 pbrCol = PBR_Direct(i.worldPos,worldNormal,albedo,rough,metal,1,shadowAtten);


                fixed4 col = tex2D(_MainTex, i.uv);
                col.xyz = pbrCol;
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
