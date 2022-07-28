using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SdfGenerate))]
public class SdfGenerateInsp : Editor
{
    public override void OnInspectorGUI() {
        base.DrawDefaultInspector();

        var sdfGenerate = target as SdfGenerate;
        if (GUILayout.Button("gen")) {
            sdfGenerate.gen();

        }
    }
}
public class SdfGenerate : MonoBehaviour
{
    public RenderTexture rt;
    public Texture texture;
    public Shader shader;
    public int spread = 16;

    public string savePath;

    public Vector2 size = new Vector2(1024, 1024);

    public void gen() {
        var sdfGenerate = this;
        if (sdfGenerate.texture == null) {
            Debug.LogErrorFormat("texture is null ");
            return;
        }

        if (sdfGenerate.shader == null) {
            Debug.LogErrorFormat("shader is null ");
            return;
        }

        if (sdfGenerate.rt != null) {
            sdfGenerate.rt.Release();
            sdfGenerate.rt = null;
        }

        System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();
        watch.Start();
        //init();计算耗时的方法


        sdfGenerate.rt = new RenderTexture((int)sdfGenerate.size.x, (int)sdfGenerate.size.y, 32, RenderTextureFormat.ARGB32);

        Material mat = new Material(sdfGenerate.shader);
        mat.hideFlags = HideFlags.DontSave;
        mat.SetFloat("_range", sdfGenerate.spread);

        var input_rt = RenderTexture.GetTemporary(new RenderTextureDescriptor(sdfGenerate.rt.width, sdfGenerate.rt.height, sdfGenerate.rt.format));

        Graphics.Blit(texture, input_rt);

        Graphics.Blit(input_rt, sdfGenerate.rt, mat);


        RenderTexture.ReleaseTemporary(input_rt);

        var rt = sdfGenerate.rt;
        Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        tex.Apply();

        var directory = Path.GetDirectoryName(sdfGenerate.savePath);
        var fileName = Path.GetFileName(sdfGenerate.savePath);

        //Debug.LogErrorFormat("path: {0}", sdfGenerate.savePath);
        //Debug.LogErrorFormat("directory: {0}", directory);
        //Debug.LogErrorFormat("fileName: {0}", fileName);

        if (!string.IsNullOrEmpty(directory)) {
            if (!Directory.Exists(directory)) {
                Directory.CreateDirectory(directory);
            }
        }
        else {
            Debug.LogErrorFormat("savePath directory no exist {0}", sdfGenerate.savePath);
            return;
        }



        File.WriteAllBytes(sdfGenerate.savePath, tex.EncodeToPNG());

        Debug.LogFormat("save png: {0}", sdfGenerate.savePath);

        watch.Stop();
        var mSeconds = watch.ElapsedMilliseconds / 1000.0;
        Debug.LogErrorFormat("耗时：{0}秒", mSeconds.ToString());
    }
}