using System;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]

public class PostProcessStacker : MonoBehaviour {

    public Shader[] shaders;

    private Material[] materials;

	void Start() 
	{
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;

        materials = new Material[shaders.Length];
        for (int i = 0; i < shaders.Length; i++)
        {
            materials[i] = new Material(shaders[i]);
        }
    }

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
        RenderTexture temp_1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        RenderTexture temp_2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

        Graphics.CopyTexture(source, temp_1);
        for (int i = 0; i < materials.Length; i++)
        {
            Graphics.Blit(temp_1, temp_2, materials[i]);
            Graphics.CopyTexture(temp_2, temp_1);
        }
        Graphics.Blit(temp_1, destination);

        RenderTexture.ReleaseTemporary(temp_1);
        RenderTexture.ReleaseTemporary(temp_2);
    }
}