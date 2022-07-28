using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
   public Shader briSatConShader;
   public Material briSatConMaterial;

   public Material material
   {
      get
      {
         briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
         return briSatConMaterial;
      }

   }

   [Range(0.0f,3.0f)]
   public float brightness = 1.0f;

   [Range(0.0f,3.0f)]
   public float saturation = 1.0f;

   [Range(0.0f,3.0f)]
   public float contrast = 1.0f;

   
   //OnRenderImage 事件，检查材质是否可用，如果可用，就把参数传递给材质，再调用Graphics.Blit 进行处理
   private void OnRenderImage(RenderTexture src, RenderTexture dest)
   {
      if (material != null)
      {
         material.SetFloat("_Brightness",brightness);
         material.SetFloat("_Saturation",saturation);
         material.SetFloat("_Contrast",contrast);
         
         Graphics.Blit(src,dest,material);
         
      }
      else
      {
         Graphics.Blit(src,dest);
      }
   }
}
