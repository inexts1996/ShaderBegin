using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MyPostProcessRendererFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        private MyPostProcessEffect effect;
        private Material material;
        private RTHandle source;
        private RTHandle destination;
        private RTHandle tempTexture;

        public CustomRenderPass(Material material)
        {
            this.material = material;
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }

        public void Setup(RTHandle source, RTHandle destination)
        {
            this.source = source;
            this.destination = destination;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;
            RenderingUtils.ReAllocateIfNeeded(ref tempTexture, descriptor, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempTexture");
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (material == null) return;

            var renderer = renderingData.cameraData.renderer;
            source = renderer.cameraColorTargetHandle;
            destination = renderer.cameraColorTargetHandle;
            CommandBuffer cmd = CommandBufferPool.Get("MyPostProcessEffect");

            if (effect == null)
            {
                VolumeStack stack = VolumeManager.instance.stack;

                effect = stack.GetComponent<MyPostProcessEffect>();
            }

            if (effect.IsActive())
            {
                Blitter.BlitCameraTexture(cmd, this.source, this.tempTexture);
                Blitter.BlitCameraTexture(cmd, this.tempTexture, destination, material, 0);
                // CoreUtils.SetRenderTarget(cmd, this.destination);

                material.SetFloat("_Brightness", effect.intensity.value);
            }
            else
            {
                Blitter.BlitCameraTexture(cmd, source, destination);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            tempTexture?.Release();
        }
    }
    
    private CustomRenderPass renderPass;
    public Shader shader;
    private Material material;

    public override void Create()
    {
        if (shader == null) return;

        material = CoreUtils.CreateEngineMaterial(shader);
        renderPass = new CustomRenderPass(material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (material == null) return;

        // renderPass.Setup(renderer.cameraColorTargetHandle, renderer.cameraColorTargetHandle);
        renderer.EnqueuePass(renderPass);
    }

    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(material);
    }
}