using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class ShadowSync : MonoBehaviour
{
    private string C_PropName = "_ShadowLightDirection";
    public Material[] materialList;
    public Vector4 ShadowDir;
    public Color ShadowColor;
    
    public void Start()
    {
        //获取gameobj以及 子节点的所有SkinnedMeshRenderer组件
        var meshes = GetComponentsInChildren<SkinnedMeshRenderer>();
        
        //遍历每一个skinnedmeshRenderer
        foreach (var mesh in meshes)
        {
            //获取该skinned上挂在的所有材质
            //sharedMaterials 比起material  具有保护  只占内存一份的特点
            var mats = mesh.sharedMaterials;
            
            
            //遍历所有材质
            foreach (var mat in mats)
            {
                // //如果该材质没有对应的属性则跳过本次循环，不执行以下，进入下一个循环
                // if (!mat.HasProperty(C_PropName))
                //     continue;
                //
                // //得到材质的向量属性
                // var vect = mat.GetVector(C_PropName);
                //
                // //将该gameobj transform的Y轴赋予 材质向量的W轴
                // vect.w = transform.position.y;
                //
                // //设置新的C_PropName  值  初始化
                // mat.SetVector(C_PropName, vect);
                
                if( !mat.HasProperty("_ShadowLightColor") && !mat.HasProperty(C_PropName) )
                    continue;
                mat.SetColor("_ShadowLightColor",ShadowColor);
                mat.SetVector(C_PropName,ShadowDir);

           
                
            }
        }
    }
    
    
    
    private void  Update()
    {   
        //这个宏 不会再打包后运行，只会在编辑器中运行
        #if UNITY_EDITOR
            // print("sssss");
            foreach(var mat in materialList)
            {
                if( !mat.HasProperty("_ShadowLightColor") && !mat.HasProperty(C_PropName))
                    continue;
                mat.SetColor("_ShadowLightColor",ShadowColor);
                mat.SetVector(C_PropName,ShadowDir);
 
            }
        #endif
        
    }
    
 

}
