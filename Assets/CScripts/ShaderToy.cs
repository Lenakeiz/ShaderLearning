﻿using System;
using UnityEngine;

[ExecuteInEditMode]
public class ShaderToy : UnityStandardAssets.ImageEffects.ImageEffectBase
{

    public int horizontalResolution = 320;
    public int verticalResolution = 240;

    // Called by camera to apply image effect
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // To draw the shader at full resolution, use:
        // Graphics.Blit (source, destination, material);

        // To draw the shader at scaled down resolution, use:
        RenderTexture scaled = RenderTexture.GetTemporary(horizontalResolution, verticalResolution);
        Graphics.Blit(source, scaled, material);
        Graphics.Blit(scaled, destination);
        RenderTexture.ReleaseTemporary(scaled);
    }
}