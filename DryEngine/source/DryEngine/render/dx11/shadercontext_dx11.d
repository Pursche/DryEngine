module DryEngine.render.dx11.shadercontext_dx11;

import DryEngine.render.shadercontext;
import DryEngine.render.types;
import DryEngine.render.material;

import directx.d3d11;

import core.stdc.string;

class ShaderContext_DX11 : ShaderContext
{
    ID3D11DeviceContext _d3dctx;
    ID3D11Buffer _materialBuffer;

    override void SetResource(string name, RenderResourceHandle tex)
    {

    }

    override void SetMaterials(const MaterialDef def, const void*[] materials)
    {
        D3D11_MAPPED_SUBRESOURCE ms;
        if (SUCCEEDED(_d3dctx.Map(_materialBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &ms)))
        {
            char* dst = cast(char*)(ms.pData);
            foreach (src; materials)
            {
                memcpy(dst, src, def.stride);
                dst += def.stride;
            }

            _d3dctx.Unmap(_materialBuffer, 0);
        }
    }
}
