module DryEngine.render.dx11.utils_dx11;

import DryEngine.render.types;

import directx.d3d11;

public D3D11_USAGE GetDX11Usage(RenderResourceUsage usage)
{
    final switch (usage)
    {
        case RenderResourceUsage.Default: return D3D11_USAGE_DEFAULT;
        case RenderResourceUsage.Immutable: return D3D11_USAGE_IMMUTABLE;
        case RenderResourceUsage.Dynamic: return D3D11_USAGE_DYNAMIC;
        case RenderResourceUsage.Staging: return D3D11_USAGE_STAGING;
    }
}