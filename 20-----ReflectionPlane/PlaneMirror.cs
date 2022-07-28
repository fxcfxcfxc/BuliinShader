using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


[ExecuteInEditMode]
public class PlaneMirror : MonoBehaviour
{
    
    public Matrix4x4 m;
    public float clipPlaneOffser = 0.07f;
    public Camera ReflectionCamera;
    public LayerMask reflectLayers;
    
    public int textureSize = 512;
    public int OldReflectionTextureSize;
    public RenderTexture ReflectionTexture;

    public Renderer m_Renderer;
    
    //[Range(0, 5.0f)]
    //public float BlurStrength = 1.0f;
 
    //public PostProcessLayer  Post;
    
    
    
    //在具有mesh组件的 中 每帧调用
    public void OnWillRenderObject()
    {   
        
        //-----------------------------------获取renderer组件对象
        if (m_Renderer == null)
        {
            m_Renderer = GetComponent<Renderer>();
        }
        
        
        //拿到当前相机
        Camera currentCamera = Camera.current;
        
        //------------------------------------初始化反射贴图  ,如重新设置过贴图大小，那么就重新执行，或者 RT为空 就执行 
        if (!ReflectionTexture ||  OldReflectionTextureSize != textureSize )
        {
            if (ReflectionTexture)
            {   
                //DestroyImmediate 立即销毁
                DestroyImmediate(ReflectionTexture);
            }
  
            ReflectionTexture = RenderTexture.GetTemporary(textureSize, textureSize, 16,RenderTextureFormat.ARGBFloat);
            ReflectionTexture.name = "_Reflection" + GetInstanceID();
            ReflectionTexture.isPowerOfTwo = true;
            ReflectionTexture.hideFlags = HideFlags.DontSave;
            ReflectionTexture.autoGenerateMips = true;
            ReflectionTexture.useMipMap = true;
            
            OldReflectionTextureSize = textureSize;
  
        }
 
        //-----------------------------------------------初始化相机 ，执行一次
        if (!ReflectionCamera)
        {
            GameObject go = new GameObject("reflection camera id" + GetInstanceID() + " for " + currentCamera.GetInstanceID(), typeof(Camera));
            ReflectionCamera = go.GetComponent<Camera>();
            //Post = go.AddComponent<PostProcessLayer>();
            //LayerMask mask = 1<<7;
            //Post.volumeLayer = mask;
            ReflectionCamera.enabled = false;
            go.hideFlags = HideFlags.HideAndDontSave;
        }
        
        //更新相机
        ReflectionCamera.CopyFrom(currentCamera);
        
        
        // -------------------------------------------计算出反射的平面 Vector4 代表  法线表示法  
        Vector3 pos = transform.position;
        Vector3 normal = transform.up;
        float d = -Vector3.Dot(normal, pos) - clipPlaneOffser;
        Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);
        
        
        
        //得到镜像矩阵
        m = default(Matrix4x4);
        m = CalculateReflectionMatrix(m,reflectionPlane);
        
        
        
        //相机使用镜像矩阵
        ReflectionCamera.worldToCameraMatrix = currentCamera.worldToCameraMatrix * m;
        
        
        
        //--------------------------------------修复物体穿过平面，反射错误的原因---------
        //用反射平面，作为新的反摄像机近裁切面，来设置新的  project 矩阵
        Vector4 newclipPlane =  ReflectionCamera.worldToCameraMatrix.inverse.transpose * reflectionPlane;
        ReflectionCamera.projectionMatrix = GetObliqueMatrix(ReflectionCamera, newclipPlane);
        
        
        //-------------------------------------------------------设置渲染
        //设置反射的物体
        ReflectionCamera.cullingMask = reflectLayers;
        ReflectionCamera.targetTexture = ReflectionTexture;
        GL.invertCulling = true;
        ReflectionCamera.Render();
        GL.invertCulling = false;

        
        //ReflectionTexture.GenerateMips();
        m_Renderer.sharedMaterial.SetTexture("_MainTex",ReflectionTexture);
      
    }

 
    //计算镜像相机矩阵
    private Matrix4x4 CalculateReflectionMatrix(Matrix4x4 m, Vector4 plane)
    {   
        //矩阵第一行
        m.m00 = -2 * plane.x * plane.x + 1;
        m.m01 = -2 * plane.x * plane.y;
        m.m02 = -2 * plane.x * plane.z;
        m.m03 = -2 * plane.x * plane.w;

        //矩阵第二行
        m.m10 = -2 * plane.x * plane.y;
        m.m11 = -2 * plane.y * plane.y + 1;
        m.m12 = -2 * plane.y * plane.z;
        m.m13 = -2 * plane.y * plane.w;
        
        //第三行
        m.m20 = -2 * plane.z * plane.x;
        m.m21 = -2 * plane.z * plane.y;
        m.m22 = -2 * plane.z * plane.z + 1;
        m.m23 = -2 * plane.z * plane.w;

        //第四行
        m.m30 = 0;
        m.m31 = 0;
        m.m32 = 0;
        m.m33 = 1;

        return m;

    }
    
    
    //计算反摄像机新的投影矩阵
    private Matrix4x4 GetObliqueMatrix(Camera camera, Vector4 viewSpaceClipPlane)
    {

        var M = camera.projectionMatrix;
        var m4 = new Vector4(M.m30, M.m31, M.m32 ,M.m33);
        var viewC = viewSpaceClipPlane;
        var clipC = M.inverse.transpose * viewC;

        var clipQ = new Vector4(Mathf.Sign(clipC.x), Mathf.Sign(clipC.y), 1, 1);
        var viewQ = M.inverse * clipQ;

        var a = 2 * Vector4.Dot(m4, viewQ) / Vector4.Dot(viewC, viewQ);
        var aC = a * viewC;

        var newM3 = aC - m4;

        M.m20 = newM3.x;
        M.m21 = newM3.y;
        M.m22 = newM3.z;
        M.m23 = newM3.w;

        return M;

    }
    
    
    //组件关闭时调用， 释放RT
    private void OnDisable()
    {
        if (ReflectionTexture != null)
        {
            ReflectionTexture.Release();
        }
        
        
        
      
    }
    
 
    
    
    
}
