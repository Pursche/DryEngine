module DryEngine.render.mesh;

import DryEngine.render.types;
import DryEngine.render.renderer;

import gl3n.linalg;

// todo: what about dynamic meshes???
class Mesh
{
    private RenderResourceHandle _positionBuffer;
    private RenderResourceHandle _normalBitangentBuffer;
    private RenderResourceHandle _indexBuffer;

    public auto GetPosBuffer() { return _positionBuffer; }
    public auto GetNormalBitangentBuffer() { return _normalBitangentBuffer; }
    public auto GetIndexBuffer() { return _indexBuffer; }

    public this(const vec3[] pos, const uint[] indices)
    {
        {
            RenderBufferDesc desc;
            desc.data = cast(void*)(pos.ptr);
            desc.size = pos.sizeof;
            desc.bindFlags = RenderResourceBindFlag.VertexBuffer;
            desc.usage = RenderResourceUsage.Immutable;
            _positionBuffer = Renderer.Get().CreateBuffer(desc);
        }

        //{
        //    RenderBufferDesc desc;
        //    desc.data = pos.ptr;
        //    desc.size = pos.sizeof;
        //    desc.bindFlags = RenderResourceBindFlag.VertexBuffer;
        //    desc.usage = RenderResourceUsage.Immutable;
        //    _normalBitangentBuffer = Renderer.Get().CreateBuffer(desc);
        //}

        {
            RenderBufferDesc desc;
            desc.data = cast(void*)(indices.ptr);
            desc.size = indices.sizeof;
            desc.bindFlags = RenderResourceBindFlag.IndexBuffer;
            desc.usage = RenderResourceUsage.Immutable;
            _indexBuffer = Renderer.Get().CreateBuffer(desc);
        }
    }
}