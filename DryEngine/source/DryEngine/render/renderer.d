module DryEngine.render.renderer;

import DryEngine.render.types;

import gl3n.linalg;

enum RenderViewType
{
    Main,
    Shadow,
    Reflect,
}

struct RenderView
{
    mat4 matView;
    mat4 matProj;
    RenderViewType type;
}

class Renderer 
{
    static protected Renderer _instance;

    static public RenderResourceHandle CreateTexture(const RenderTextureDesc desc)
    {
        return _instance._CreateTexture(desc);
    }

    static public RenderResourceHandle CreateBuffer(const RenderBufferDesc desc)
    {
        return _instance._CreateBuffer(desc);
    }

    protected abstract RenderResourceHandle _CreateTexture(const RenderTextureDesc desc);
    protected abstract RenderResourceHandle _CreateBuffer(const RenderBufferDesc desc);
}