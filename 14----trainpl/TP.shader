Shader"Myshader/TriPlanar"
{
	  Properties
	  {	  
		//_Crontrol("范围",range(0.0,1.0))=1.0
		_Shapness("对比",float)=1.0
		[Space(10)]_ColorTex("主颜色贴图",2D)="gray"{}
		_ColorTexPow("主要颜色强度",float)=1.0
		_ColorScale("主颜色贴图重复率",float)=1.0
	
		_NormalTex("主法线贴图",2D)="bump"{}
		_NormalScale("法线强度",range(0.0,1.0))=1.0
		[Space(50)][Header(UpTEXTURE)]
		_ColorUpTex("朝上地形贴图",2D)="gray"{}
		_ColorUpTexPow("朝上颜色强度",float)=1.0
		_ColorUpScale("朝上地形贴图重复率",float)=1.0

		_NormalUpTex("朝上法线贴图",2D)="bump"{}

		[Space(20)]_SpecularPow("高光强度",float)=1

  
	  }
	  SubShader
	  {
		   Tags{"RenderType"="Opaque"}

		   pass
		   {	Tags {"LightMode"="ForwardBase"}//得到unity正确的光照属性
		   		CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "AutoLight.cginc"
				#include "Lighting.cginc"
				#include "UnityCG.cginc"
				#pragma multi_complie_fwdbase_fullshadows
				#pragma target3.0


				uniform sampler2D _ColorTex;
			    uniform sampler2D _NormalTex;
				uniform sampler2D _NormalUpTex;
				uniform sampler2D _ColorUpTex;								 
				uniform float _ColorScale;
				uniform float _ColorUpScale;
				uniform float _Shapness;
				uniform float _ColorTexPow;
				uniform float _ColorUpTexPow;
				uniform float _SpecularPow;
				uniform float _NormalScale;  
				//uniform float _Crontrol;

								  



				struct a2f
				{
				   float4 vertex :POSITION;
				   float2 uv :TEXCOORD0;
				   float3 normal:NORMAL;
				   float4 tangent :TANGENT;



				};

				struct v2f
				{
					float4 pos:SV_POSITION;
					float2 uv0:TEXCOORD0;
					float3 posWS:TEXCOORD1;
					float3 nDirWS:TEXCOORD2;
					float3 tDirWS:TEXCOORD3;//切线向量
                    float3 bDirWS:TEXCOORD4;//副切线向量
					LIGHTING_COORDS(5,6)



				};


				v2f vert(a2f v)
				{
				   v2f o;
				   o.pos = UnityObjectToClipPos(v.vertex);
				   o.posWS = mul(unity_ObjectToWorld,v.vertex);
				   o.nDirWS =UnityObjectToWorldNormal(v.normal);//得到顶点世界空间下的法线向量
				   o.tDirWS =normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);//得到顶点世界空间下的切线向量
				   o.bDirWS =normalize(cross(o.nDirWS,o.tDirWS) * v.tangent.w);//得到顶点世界空间下的法线向量
				   TRANSFER_VERTEX_TO_FRAGMENT(o)
				   o.uv0 = v.uv;
				   return o;


				}


				half4 frag(v2f i):SV_Target//逐像素执行
				{
					 float3 nDirTS =UnpackNormal(tex2D(_NormalTex,i.uv0));//采样该像素的法线值（切线空间下的值）
					 nDirTS.xy = nDirTS * _NormalScale;//法线强度控制 
                     float3x3 TBN = float3x3(i.tDirWS,i.bDirWS,i.nDirWS);//构造TBN矩阵
	 
					 float3 nDir = normalize(mul(nDirTS,TBN));//将法线从切线空间转换到世界空间				
					 float3 lDir = _WorldSpaceLightPos0.xyz; //光方向
					 float3 vDir = normalize(_WorldSpaceCameraPos.xyz-i.posWS);//视角方向
					 float3 hDir = normalize(vDir+lDir);//半角方向


					 float ndoth = dot(nDir,hDir);
					 float ndotl = dot(nDir,lDir);

					 float lambert = max(0.0,ndotl);//lambert光照
					 //float blinn_phone = pow(max(0.0,ndoth),_SpecularPow);

					 float shadow = LIGHT_ATTENUATION(i);//获取投影颜色值


					//分别采样三个方向贴图颜色
					float3 mask = pow(normalize(abs(nDir)),_Shapness);//三个分量的mask
					mask =	mask/(mask.x+mask.y+mask.z);//?
					
					float3 xyColor = tex2D(_ColorTex,i.posWS.xy/_ColorScale)* mask.z;
					float3 xzColor = tex2D(_ColorUpTex,i.posWS.xz/_ColorUpScale)* mask.y;
					float3 yzColor = tex2D(_ColorTex,i.posWS.yz/_ColorScale)* mask.x;
					float3 finalcolor = xyColor*_ColorTexPow + xzColor * _ColorUpTexPow + yzColor *_ColorTexPow;


					//最终合并光照
					finalcolor = finalcolor*lambert*shadow;
					 

				
					return half4(finalcolor,1.0);

				}																							   
				ENDCG									          



		   }

	   
	  }
	  fallback"Diffuse"

}