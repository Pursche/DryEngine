module DryEngine.render.renderer;

import DryEngine.render.types;

class Renderer 
{
    static Renderer _instance;
    static public Renderer Get()
    {
        return _instance;
    }

    public RenderResourceHandle CreateTexture(const RenderTextureDesc desc)
    {
        const RenderResourceHandle handle = 0; // todo
        if (!InitTexture(handle, desc))
        {
            return cast(RenderResourceHandle)(0xffffffff);
        }
        return handle;
    }

    public RenderResourceHandle CreateBuffer(const RenderBufferDesc desc)
    {
        const RenderResourceHandle handle = 0; // todo
        if (!InitBuffer(handle, desc))
        {
            return cast(RenderResourceHandle)(0xffffffff);
        }
        return handle;
    }

    protected abstract bool InitTexture(RenderResourceHandle handle, const RenderTextureDesc desc);
    protected abstract bool InitBuffer(RenderResourceHandle handle, const RenderBufferDesc desc);
}