module render.types;

import std.typecons;

alias RenderResourceHandle = Typedef!(uint, 0xffffffff);

enum RenderFormat
{
    R8_UNORM,
    R8_SNORM,
    R8_UINT,
    R8_SINT,

    R8G8_UNORM,
    R8G8_SNORM,
    R8G8_UINT,
    R8G8_SINT,

    R8G8B8A8_UNORM,
    R8G8B8A8_SNORM,
    R8G8B8A8_UINT,
    R8G8B8A8_SINT,

    R16_UNORM,
    R16_SNORM,
    R16_UINT,
    R16_SINT,
    R16_FLOAT,

    R16G16_UNORM,
    R16G16_SNORM,
    R16G16_UINT,
    R16G16_SINT,
    R16G16_FLOAT,

    R16G16B16A16_UNORM,
    R16G16B16A16_SNORM,
    R16G16B16A16_UINT,
    R16G16B16A16_SINT,
    R16G16B16A16_FLOAT,

    R32_UNORM,
    R32_SNORM,
    R32_UINT,
    R32_SINT,
    R32_FLOAT,

    R32G32_UNORM,
    R32G32_SNORM,
    R32G32_UINT,
    R32G32_SINT,
    R32G32_FLOAT,

    R32G32B32_UNORM,
    R32G32B32_SNORM,
    R32G32B32_UINT,
    R32G32B32_SINT,
    R32G32B32_FLOAT,

    R32G32B32A32_UNORM,
    R32G32B32A32_SNORM,
    R32G32B32A32_UINT,
    R32G32B32A32_SINT,
    R32G32B32A32_FLOAT,

    R10G10B10A2_UNORM,
    R10G10B10A2_UINT,
}

enum PrimitiveTopology
{
    PointList,
    LineList,
    LineStrip,
    TriangleList,
    TriangleStrip,
}

enum RenderTextureType
{
    Texture1D,
    Texture1DArray,
    Texture2D,
    Texture2DArray,
    Texture3D,
}

enum RenderResourceUsage
{
    Default,
    Immutable,
    Dynamic,
}

enum RenderResourceBindFlag
{
    VertexBuffer    = 1 << 0,
    IndexBuffer     = 1 << 1,
    ShaderResource  = 1 << 2,
    UnorderedAccess = 1 << 3,
    ConstantBuffer  = 1 << 4,
    RenderTarget    = 1 << 5,
    DepthStencil    = 1 << 6,
}

struct RenderTextureDesc
{
    uint width;
    uint height;
    union 
    {
        uint depth;
        uint arraySlices;
    }
    uint mipLevels;
    RenderTextureType type;
    RenderResourceBindFlag bindFlags;
    RenderFormat format;
    RenderResourceUsage usage;
    void* data;
    uint dataRowPitch;
    uint dataSlicePitch;
}

struct RenderBufferDesc
{
    uint size;
    RenderFormat format;
    RenderResourceBindFlag bindFlags;
    RenderResourceUsage usage;
    void* data;
}