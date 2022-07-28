using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//可以在编辑器状态下执行该脚本
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();

        if (isSupported == false)
        {
            NotSupported();
            
        }
    }


    protected bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("THis platform dose not support image effects or render textures");
            return false;
        }
        return true;

    }

    protected void NotSupported()
    {
        enabled = false;
    }
    
    
    
    //CheckShaderAndCreateMaterial 方法 接受两个参数，第一个指定了该特效需要使用的shader
    //第二个参数则是用于处理后处理的材质，该函数首先检查shader可用性，检查通过后就返回一个使用了该shader的材质，否则null
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
            
        }

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }
                


        }
    }

    void Start()
    {
        CheckResources();
    }

    

}
