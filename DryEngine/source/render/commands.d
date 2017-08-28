module render.commands;

import render.types;

struct Cmd_Draw
{
    RenderResourceHandle[] vertexBuffers;
    RenderResourceHandle indexBuffer;
    RenderResourceHandle[] resources;
    uint indexCount;
    uint indexOffset;
    uint vertexOffset;
    PrimitiveTopology topology;
}

struct Cmd_DrawInstanced
{
    RenderResourceHandle[] vertexBuffers;
    RenderResourceHandle indexBuffer;
    RenderResourceHandle[] resources;
    uint indexCount;
    uint indexOffset;
    uint vertexOffset;
    uint instanceCount;
    uint instanceOffset;
    PrimitiveTopology topology;
}

struct Cmd_Dispatch
{
    uint groupCountX;
    uint groupCountY;
    uint groupCountZ;
}


struct Cmd_DispatchIndirect
{
    RenderResourceHandle args;
}

struct Cmd_UpdateTexture1D
{
    RenderResourceHandle texture;
    uint mipSlice;
    void* data;
}

struct Cmd_UpdateTexture1DArray
{
    RenderResourceHandle texture;
    uint mipSlice;
    uint arraySlice;
    void* data;
}

struct Cmd_UpdateTexture2D
{
    RenderResourceHandle texture;
    uint mipSlice;
    void* data;
}

struct Cmd_UpdateTexture2DArray
{
    RenderResourceHandle texture;
    uint mipSlice;
    uint arraySlice;
    void* data;
}

struct Cmd_UpdateTexture3D
{
    RenderResourceHandle texture;
    uint mipSlice;
    void* data;
}
