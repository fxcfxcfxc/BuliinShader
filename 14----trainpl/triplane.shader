// Standard shader with triplanar mapping
// https://github.com/keijiro/StandardTriplanar

Shader "Triplanar"
{
    Properties
    {
        _Color("color", Color) = (1, 1, 1, 1)
        _MainTex("TriMap", 2D) = "white" {}
        _BaseTex("BaseMap", 2D) = "black" {}
 

        _Glossiness("smooth", Range(0, 1)) = 0.5
        [Gamma] _Metallic("metal", Range(0, 1)) = 0

        _BumpScale("bumpscale", Float) = 1
        _BumpMap("bump", 2D) = "bump" {}

      //  _OcclusionStrength("", Range(0, 1)) = 1
      //  _OcclusionMap("oc", 2D) = "white" {}

        _MapScale("scale", Float) = 1
        _RotationAngle("RotationAngle", Float) = 1

    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }

            CGPROGRAM

            #pragma surface surf Standard vertex:vert fullforwardshadows addshadow

           // #pragma shader_feature _NORMALMAP
          //  #pragma shader_feature _OCCLUSIONMAP

            #pragma target 3.5

            half4 _Color;
            sampler2D _MainTex, _DetailMaskTex, _BaseTex;

            half _Glossiness;
            half _Metallic;

            half _BumpScale;
            sampler2D _BumpMap;

            half _OcclusionStrength;
            sampler2D _OcclusionMap;

            half _MapScale;
            float _RotationAngle;

            struct Input
            {
                float3 localCoord;
                float3 localNormal;
                float2 uv_MainTex;
                float4 verCol;
            };

            void vert(inout appdata_full v, out Input data)
            {
                UNITY_INITIALIZE_OUTPUT(Input, data);
                data.localCoord = mul(unity_ObjectToWorld,v.vertex);
                data.localNormal = normalize(mul(float4(v.normal, 0.0), unity_ObjectToWorld).xyz);

              //  data.localNormal = data.localNormal.xzy;
                data.uv_MainTex = v.texcoord;
                data.verCol = v.color;
            }

            fixed4 TriProj(sampler2D tex, half3 worldNormal, half3 worldPos, half mapScale)
            {

                float3 bf = normalize(abs(worldNormal));
                bf /= dot(bf, (float3)1);

                // Triplanar mapping
               // mapScale *= 0.01;
                float2 tx = worldPos.yz * mapScale;
                float2 ty = worldPos.zx * mapScale;
                float2 tz = worldPos.xy * mapScale;
                // Base color
                half4 cx = tex2D(tex, tx) * bf.x;
                half4 cy = tex2D(tex, ty) * bf.y;
                half4 cz = tex2D(tex, tz) * bf.z;

                half4 color = (cx + cy + cz);

                return color;
            }

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                float2 uv = IN.uv_MainTex;
                // Blending factor of triplanar mapping
                float3 bf = normalize(abs(IN.localNormal));
                bf /= dot(bf, (float3)1);

                // Triplanar mapping
                _MapScale *= 0.01;
                float2 tx = IN.localCoord.yz * _MapScale;
                float2 ty = IN.localCoord.zx * _MapScale;
                float2 tz = IN.localCoord.xy * _MapScale;

                // Base color
                half4 cx = tex2D(_MainTex, tx) * bf.x;
               
                
                half4 cy = tex2D(_MainTex, ty) * bf.y;
                half4 cz = tex2D(_MainTex, tz) * bf.z;
             
                half4 color = (cx + cy + cz) * _Color;

              
                o.Albedo = TriProj(_MainTex, IN.localNormal, IN.localCoord, _MapScale)* _Color;
       
              //  o.Alpha = color.a;

                 uv = IN.uv_MainTex;

                


                half4 base = tex2D(_BaseTex, uv);
               o.Albedo = lerp(o.Albedo, base, saturate(IN.verCol.r * 1));
              //  o.Albedo = IN.verCol.r;

           // #ifdef _NORMALMAP
                // Normal map
                half4 nx = tex2D(_BumpMap, tx) * bf.x;
                half4 ny = tex2D(_BumpMap, ty) * bf.y;
                half4 nz = tex2D(_BumpMap, tz) * bf.z;
                o.Normal = UnpackScaleNormal(TriProj(_BumpMap, IN.localNormal, IN.localCoord, _MapScale), _BumpScale);
           // #endif

  

                // Misc parameters
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
            }
            ENDCG
        }
            FallBack "Diffuse"
                CustomEditor "StandardTriplanarInspector"
}
