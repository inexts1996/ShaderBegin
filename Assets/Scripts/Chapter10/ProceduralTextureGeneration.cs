using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material;
    private Texture2D m_generatedTexture;

    #region Material  properties

    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;

    public int textureWidth
    {
        get { return m_textureWidth; }
        set
        {
            m_textureWidth = value;
            UpdateMaterial();
        }
    }


    private void UpdateMaterial()
    {
        if (material == null) return;

        m_generatedTexture = GenerateProceduralTexture();
        material.SetTexture("_MainTex", m_generatedTexture);
    }

    private Texture2D GenerateProceduralTexture()
    {
        var texture = new Texture2D(textureWidth, textureWidth);

        var circleInterval = textureWidth / 4.0f;
        var radius = textureWidth / 10.0f;
        float edgeBlur = 1.0f / blurFactor;

        for (int i = 0; i < textureWidth; i++)
        {
            for (int j = 0; j < textureWidth; j++)
            {
                Color pixel = backgroundColor;

                for (int k = 0; k < 4; k++)
                {
                    for (int l = 0; l < 4; l++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (k + 1), circleInterval * (l + 1));
                        float dist = Vector2.Distance(new Vector2(i, j), circleCenter) - radius;

                        Color color = MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0f), Mathf.SmoothStep(0f, 1f, dist * edgeBlur));
                        pixel = MixColor(pixel, color, color.a);
                    }
                }

                texture.SetPixel(i, j, pixel);
            }
        }

        texture.Apply();

        return texture;
    }

    private Color MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;

    public Color backgroundColor
    {
        get { return m_backgroundColor; }
        set
        {
            m_backgroundColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;

    public Color circleColor
    {
        get { return m_circleColor; }
        set
        {
            m_circleColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;

    public float blurFactor
    {
        get { return m_blurFactor; }
        set
        {
            m_blurFactor = value;
            UpdateMaterial();
        }
    }

    #endregion

    void Start()
    {
        if (material == null)
        {
            var renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null) return;
            material = renderer.sharedMaterial;
        }

        UpdateMaterial();
    }
}