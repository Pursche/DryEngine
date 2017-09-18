module DryEngine.render.dx11.renderer_dx11;

import DryEngine.render.renderer;
import DryEngine.render.types;
import DryEngine.render.dx11.utils_dx11;

import directx.d3d11;

class Renderer_DX11 : Renderer
{
    private ID3D11Device _device;
    private ID3D11DeviceContext _immediateContext;

    private ID3D11Resource[] _resources;
    private ID3D11ShaderResourceView[] _srvs;
    private ID3D11UnorderedAccessView[] _uavs;

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
        _device.GetImmediateContext(&_immediateContext);

        _resources = new ID3D11Resource[1024];
        _srvs = new ID3D11ShaderResourceView[1024];
        _uavs = new ID3D11UnorderedAccessView[1024];
    }

    override protected bool InitTexture(RenderResourceHandle handle, const RenderTextureDesc desc)
    {
        ID3D11Resource resource;

        // todo

        _resources[cast(size_t)(handle)] = resource;
        _srvs[cast(size_t)(handle)] = null;
        _uavs[cast(size_t)(handle)] = null;
        return true;
    }

    override protected bool InitBuffer(RenderResourceHandle handle, const RenderBufferDesc desc)
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

        _resources[cast(size_t)(handle)] = buffer;
        _srvs[cast(size_t)(handle)] = srv;
        _uavs[cast(size_t)(handle)] = uav;
        return true;
    }

    public ID3D11Device GetD3DDevice()
    {
        return _device;
    }
}