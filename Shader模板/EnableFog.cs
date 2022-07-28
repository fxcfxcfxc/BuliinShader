using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class EnableFog : MonoBehaviour
{
    public bool AddFog = true;
    public FogMode FogStyle = FogMode.Linear;
    public Color FogColor =Color.gray ;
    public float ExponentialFogDensity = 0.2f;
    public float LinearFogStartDistance;
    public float LinearFogEndDistance = 10.0f;

    private void Update()
    
    {
        RenderSettings.fog= AddFog;
        RenderSettings.fogMode = FogStyle;
        RenderSettings.fogColor = FogColor;
        RenderSettings.fogDensity = ExponentialFogDensity;
        RenderSettings.fogStartDistance = LinearFogStartDistance;
        RenderSettings.fogEndDistance = LinearFogEndDistance;


    }
    
    
}
