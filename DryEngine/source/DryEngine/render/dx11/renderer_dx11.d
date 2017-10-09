module DryEngine.render.dx11.renderer_dx11;

import DryEngine.render.renderer;
import DryEngine.render.types;
import DryEngine.render.dx11.utils_dx11;
import DryEngine.render.material;

import directx.d3d11;

class Renderer_DX11 : Renderer
{
    private ID3D11Device _device;
    private ID3D11DeviceContext _context;

    private ID3D11Resource[] _resources;
    private ID3D11ShaderResourceView[] _srvs;
    private ID3D11UnorderedAccessView[] _uavs;

    private ID3D11Buffer _materialBuffer;
    private ID3D11ShaderResourceView _materialBufferSRV;

    private size_t _currentBufferIndex = 0;

    private MaterialDef[] _materialDefs;
    private size_t[] _materialDataSize; // Size of relevant data.
    private char[][] _materialData;

    static public Renderer_DX11 Get()
    {
        return cast(Renderer_DX11)(_instance);
    }

    static public void Init(ID3D11Device device)
    {
        _instance = new Renderer_DX11(device);
    }

    private this(ID3D11Device device)
    {
        _device = device;
        _device.GetImmediateContext(&_context);

        _resources = new ID3D11Resource[1024];
        _srvs = new ID3D11ShaderResourceView[1024];
        _uavs = new ID3D11UnorderedAccessView[1024];

        {
            D3D11_BUFFER_DESC bd;
            bd.ByteWidth = 1 * 1024 * 1024;
            bd.Usage = D3D11_USAGE_DYNAMIC;
            bd.BindFlags = D3D11_BIND_SHADER_RESOURCE;
            bd.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
            bd.MiscFlags = 0;
            
            _device.CreateBuffer(&bd, null, &_materialBuffer);
            _device.CreateShaderResourceView(_materialBuffer, null, &_materialBufferSRV);
        }
    }

    override protected RenderResourceHandle _CreateTexture(const RenderTextureDesc desc)
    {
        ID3D11Resource resource;
        ID3D11ShaderResourceView srv;
        ID3D11UnorderedAccessView uav;



        RenderResourceHandle handle = 0;//todo
        _resources[cast(size_t)(handle)] = resource;
        _srvs[cast(size_t)(handle)] = null;
        _uavs[cast(size_t)(handle)] = null;
        return handle;
    }

    override protected RenderResourceHandle _CreateBuffer(const RenderBufferDesc desc)
    {
        ID3D11ShaderResourceView srv = null;
        ID3D11UnorderedAccessView uav = null;

        D3D11_BUFFER_DESC bd;
        bd.Usage = GetDX11Usage(desc.usage);
        bd.ByteWidth = desc.size;

        D3D11_SUBRESOURCE_DATA sd;
        sd.pSysMem = cast(void*)(desc.data);

        ID3D11Buffer buffer;
        _device.CreateBuffer(&bd, &sd, &buffer);

        if (desc.bindFlags & RenderResourceBindFlag.ShaderResource)
        {
            _device.CreateShaderResourceView(buffer, null, &srv);
        }

        if (desc.bindFlags & RenderResourceBindFlag.UnorderedAccess)
        {
            _device.CreateUnorderedAccessView(buffer, null, &uav);
        }

        RenderResourceHandle handle = 0;//todo
        _resources[cast(size_t)(handle)] = buffer;
        _srvs[cast(size_t)(handle)] = srv;
        _uavs[cast(size_t)(handle)] = uav;
        return handle;
    }

    public ID3D11Device GetD3DDevice()
    {
        return _device;
    }

    public void Draw()
    {
        import core.stdc.string : memcpy;

        // Flip buffers.
        _currentBufferIndex = (_currentBufferIndex + 1) & 1;

        // Update material buffer.
        // Group by MaterialDef.
        size_t[] materialIdOffsets = new size_t[_materialDefs.length];
        {
            D3D11_MAPPED_SUBRESOURCE ms;
            _context.Map(_materialBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &ms);
            char* dstMaterialData = cast(char*)(ms.pData);
            foreach (i, def; _materialDefs)
            {
                materialIdOffsets[i] = dstMaterialData - ms.pData;
                const size_t materialDataSize = _materialDataSize[i];
                memcpy(dstMaterialData, _materialData[i].ptr, materialDataSize);
                dstMaterialData += materialDataSize;
            }
            _context.Unmap(_materialBuffer, 0);
        }

        // Bind material buffer.
        _context.VSSetShaderResources(0, 1, &_materialBufferSRV);
        _context.PSSetShaderResources(0, 1, &_materialBufferSRV);

        // Depth prepass.
        void*[] drawCommands;
        foreach (cmd; drawCommands)
        {

        }
    }
}