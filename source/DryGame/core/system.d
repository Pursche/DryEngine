module DryGame.core.system;

import std.stdio;

import DryGame.ecs.ecswrapper;

import DryEngine.render.dx11.renderer_dx11;

import directx.d3d11;
import directx.d3dcompiler;

class System
{
    ID3D11Buffer _vertexBuffer;
    ID3D11Buffer _indexBuffer;

    ID3D11InputLayout _inputLayout;

    ID3D11VertexShader _vs;
    ID3D11PixelShader _ps;

    ID3D11BlendState _blendState;
    ID3D11RasterizerState _rasterizerState;
    ID3D11DepthStencilState _depthStencilState;

    struct TriangleVertex
    {
        float x, y;
        float r, g, b, a;
    }

    public this(string[] args)
    {
        DryGame.ecs.ecswrapper.LoadECS();

        ID3D11Device device = Renderer_DX11.Get().GetD3DDevice();

        // Vertex buffer.
        {
            TriangleVertex[4] vertices = [
                { -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f },
                {  1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f },
                { -1.0f,  1.0f, 0.0f, 0.0f, 1.0f, 1.0f },
                {  1.0f,  1.0f, 0.0f, 0.0f, 0.0f, 1.0f },
            ];

            D3D11_BUFFER_DESC desc;
            desc.ByteWidth = vertices.sizeof;
            desc.Usage = D3D11_USAGE_IMMUTABLE;
            desc.BindFlags = D3D11_BIND_VERTEX_BUFFER;
            desc.CPUAccessFlags = 0;
            desc.MiscFlags = 0;

            D3D11_SUBRESOURCE_DATA sd;
            sd.pSysMem = vertices.ptr;
            sd.SysMemPitch = 0;
            sd.SysMemSlicePitch = 0;

            HRESULT hr = device.CreateBuffer(&desc, &sd, &_vertexBuffer);
            assert(SUCCEEDED(hr));
        }

        // Index buffer.
        {
            uint[6] indices = [
                0, 1, 2,
                2, 1, 3,
            ];

            D3D11_BUFFER_DESC desc;
            desc.ByteWidth = indices.sizeof;
            desc.Usage = D3D11_USAGE_IMMUTABLE;
            desc.BindFlags = D3D11_BIND_INDEX_BUFFER;
            desc.CPUAccessFlags = 0;
            desc.MiscFlags = 0;

            D3D11_SUBRESOURCE_DATA sd;
            sd.pSysMem = indices.ptr;
            sd.SysMemPitch = 0;
            sd.SysMemSlicePitch = 0;

            HRESULT hr = device.CreateBuffer(&desc, &sd, &_indexBuffer);
            assert(SUCCEEDED(hr));
        }

        // Shaders
        ID3DBlob vsInputSignature = null;
        UINT shaderFlags = D3DCOMPILE_DEBUG | D3DCOMPILE_WARNINGS_ARE_ERRORS;
        {
            ID3DBlob code;
            ID3DBlob errors;
            HRESULT hr = D3DCompileFromFile(
                "data/shaders/triangle.hlsl",
                null,
                null,
                "VertexMain",
                "vs_5_0",
                shaderFlags,
                0,
                &code,
                &errors);
            if (FAILED(hr))
            {
                if (errors)
                {
                    MessageBoxA(null, cast(char*) errors.GetBufferPointer(), null, MB_ICONERROR);
                }
            }

            hr = device.CreateVertexShader(
                code.GetBufferPointer(), 
                code.GetBufferSize(),
                null,
                &_vs);
            assert(SUCCEEDED(hr));

            D3DGetBlobPart(
                code.GetBufferPointer(),
                code.GetBufferSize(),
                D3D_BLOB_INPUT_SIGNATURE_BLOB,
                0,
                &vsInputSignature);
        }
        {
            ID3DBlob code;
            ID3DBlob errors;
            HRESULT hr = D3DCompileFromFile(
                "data/shaders/triangle.hlsl",
                null,
                null,
                "PixelMain",
                "ps_5_0",
                shaderFlags,
                0,
                &code,
                &errors);
            if (FAILED(hr))
            {
                if (errors)
                {
                    MessageBoxA(null, cast(char*) errors.GetBufferPointer(), null, MB_ICONERROR);
                }
            }

            hr = device.CreatePixelShader(
                code.GetBufferPointer(), 
                code.GetBufferSize(),
                null,
                &_ps);
            assert(SUCCEEDED(hr));
        }

        // Input layout.
        {
            const(D3D11_INPUT_ELEMENT_DESC)[2] elements = [
                { "Position", 0, DXGI_FORMAT_R32G32_FLOAT,       0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0 },
                { "Color",    0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 8, D3D11_INPUT_PER_VERTEX_DATA, 0 },
            ];

            HRESULT hr = device.CreateInputLayout(
                elements.ptr, 
                cast(uint)(elements.length),
                vsInputSignature.GetBufferPointer(),
                vsInputSignature.GetBufferSize(),
                &_inputLayout);
            assert(SUCCEEDED(hr));
        }

        // Rasterizer state
        {
            D3D11_RASTERIZER_DESC rd;
            rd.FillMode = D3D11_FILL_SOLID;
            rd.CullMode = D3D11_CULL_NONE;
            rd.FrontCounterClockwise = true;
            rd.DepthBias = 0;
            rd.DepthBiasClamp = 0.0f;
            rd.SlopeScaledDepthBias = 0.0f;
            rd.DepthClipEnable = false;
            rd.ScissorEnable = false;
            rd.MultisampleEnable = false;
            rd.AntialiasedLineEnable = false;
            HRESULT hr = device.CreateRasterizerState(&rd, &_rasterizerState);
            assert(SUCCEEDED(hr));
        }

        // Depth stencil state
        {
            D3D11_DEPTH_STENCIL_DESC desc;
            desc.DepthEnable = false;
            desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ZERO;
            desc.DepthFunc = D3D11_COMPARISON_ALWAYS;
            desc.StencilEnable = false;
            desc.StencilReadMask = D3D11_DEFAULT_STENCIL_READ_MASK;
            desc.StencilWriteMask = D3D11_DEFAULT_STENCIL_WRITE_MASK;

            desc.FrontFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
            desc.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
            desc.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
            desc.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
            
            desc.BackFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
            desc.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
            desc.BackFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
            desc.BackFace.StencilFunc = D3D11_COMPARISON_ALWAYS;

            HRESULT hr = device.CreateDepthStencilState(&desc, &_depthStencilState);
            assert(SUCCEEDED(hr));
        }

        // Blend state
        {
            D3D11_BLEND_DESC desc;
            desc.AlphaToCoverageEnable = false;
            desc.IndependentBlendEnable = false;
            desc.RenderTarget[0].BlendEnable = true;
            desc.RenderTarget[0].SrcBlend = D3D11_BLEND_ONE;
            desc.RenderTarget[0].DestBlend = D3D11_BLEND_ZERO;
            desc.RenderTarget[0].BlendOp = D3D11_BLEND_OP_ADD;
            desc.RenderTarget[0].SrcBlendAlpha = D3D11_BLEND_ONE;
            desc.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
            desc.RenderTarget[0].BlendOpAlpha = D3D11_BLEND_OP_ADD;
            desc.RenderTarget[0].RenderTargetWriteMask = 0xf;

            HRESULT hr = device.CreateBlendState(&desc, &_blendState);
            assert(SUCCEEDED(hr));
        }
    }

    ~this()
    {
        DryGame.ecs.ecswrapper.UnloadECS();
    }

    public void Update(ID3D11RenderTargetView backbufferRTV)
    {
        DryGame.ecs.ecswrapper.Update(0.5f);

        ID3D11DeviceContext ctx = Renderer_DX11.Get().GetD3DContext();
        
        float[4] clearColor = [ 0.5f, 0.5f, 0.5f, 1.0f ];
        ctx.ClearRenderTargetView(backbufferRTV, clearColor.ptr);

        {
            ctx.OMSetRenderTargets(1, &backbufferRTV, null);
            ctx.OMSetDepthStencilState(_depthStencilState, 0x00000000);
            ctx.OMSetBlendState(_blendState, null, 0xffffffff);
        }

        {
            D3D11_VIEWPORT viewport;
            viewport.TopLeftX = 0.0f;
            viewport.TopLeftY = 0.0f;
            viewport.Width = 800.0f;
            viewport.Height = 600.0f;
            viewport.MinDepth = 0.0f;
            viewport.MaxDepth = 1.0f;
            ctx.RSSetViewports(1, &viewport);
            ctx.RSSetState(_rasterizerState);
        }

        {
            ctx.VSSetShader(_vs, null, 0);
            ctx.PSSetShader(_ps, null, 0);
        }

        {
            ID3D11Buffer[1] buffers = [ _vertexBuffer ];
            UINT[1] strides = [ TriangleVertex.sizeof ];
            UINT[1] offsets = [ 0 ];
            ctx.IASetVertexBuffers(0, 1, buffers.ptr, strides.ptr, offsets.ptr);
            ctx.IASetIndexBuffer(_indexBuffer, DXGI_FORMAT_R32_UINT, 0);
            ctx.IASetInputLayout(_inputLayout);
            ctx.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
        }
        
        ctx.DrawIndexed(6, 0, 0);
    }
}