module DryEngine.render.commands;

import DryEngine.render.types;

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