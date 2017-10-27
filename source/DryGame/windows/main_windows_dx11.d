module DryGame.linux.main_windows_dx11;

import core.sys.windows.windows;
import core.stdc.stdio;
import core.runtime;

import std.stdio;
import std.string;

import directx.dxgi;
import directx.d3d11;

import DryGame.core.system;
import DryEngine.render.dx11.renderer_dx11;

IDXGIFactory g_dxgiFactory;//yolo

struct Window
{
	IDXGISwapChain swapChain;
}

int DryMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	debug
	{
		AllocConsole();
		freopen("CONOUT$", "w", core.stdc.stdio.stdout);
		freopen("CONOUT$", "w", core.stdc.stdio.stderr);
	}

	HRESULT hr;

	hr = CreateDXGIFactory(&IID_IDXGIFactory, &g_dxgiFactory);
	if (FAILED(hr))
	{
		MessageBox(null, "CreateDXGIFactory failed!", null, MB_ICONERROR);
		return 1;
	}

	const D3D_FEATURE_LEVEL[] supportedFeatureLevels = [
		D3D_FEATURE_LEVEL_11_0,
	];

	uint flags = D3D11_CREATE_DEVICE_DEBUG;

	ID3D11Device device;
	hr = D3D11CreateDevice(
		null, 
		D3D_DRIVER_TYPE_HARDWARE, 
		null, 
		flags,
		supportedFeatureLevels.ptr,
		cast(uint)(supportedFeatureLevels.length),
		D3D11_SDK_VERSION, 
		&device,
		null,
		null);
	if (FAILED(hr))
	{
		MessageBox(null, "D3D11CreateDevice failed!", null, MB_ICONERROR);
		return 1;
	}

	Renderer_DX11.Init(device);

	WNDCLASS wc;
	wc.hInstance = hInstance;
	wc.lpszClassName = "DryGame";
	wc.lpfnWndProc = &WndProc;
	RegisterClass(&wc);

	RECT rect = { 0, 0, 640, 480 };
	hr = AdjustWindowRect(&rect, WS_OVERLAPPEDWINDOW, false);
	if (FAILED(hr))
	{
		MessageBox(null, "AdjustWindowRect failed!", null, MB_ICONERROR);
		return 1;
	}

	Window window;
	HWND hwnd = CreateWindow(
		wc.lpszClassName, 
		"DryGame",
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		rect.right - rect.left,
		rect.bottom - rect.top,
		null,
		null,
		null,
		&window);

	System system = new System(null);

	ShowWindow(hwnd, nCmdShow);

	while (IsWindowVisible(hwnd))
	{
		MSG msg;
		while (PeekMessage(&msg, null, 0, 0, PM_REMOVE))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

		ID3D11Texture2D backbuffer;
		window.swapChain.GetBuffer(0, &IID_ID3D11Texture2D, cast(void**)(&backbuffer));

		ID3D11RenderTargetView backbufferRTV;
		device.CreateRenderTargetView(backbuffer, null, &backbufferRTV);
    	backbuffer.Release();

		system.Update(backbufferRTV);

		window.swapChain.Present(1, 0);

		backbufferRTV.Release();
	}

	UnregisterClass(wc.lpszClassName, wc.hInstance);
	DestroyWindow(hwnd);

	g_dxgiFactory.Release();

	debug
	{
		FreeConsole();
	}

	return 0;
}

LRESULT DryProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
		case WM_CREATE:
		{
			const CREATESTRUCT* create = cast(CREATESTRUCT*)(lParam);
			Window* window = cast(Window*)(create.lpCreateParams);
			SetWindowLongPtr(hwnd, GWLP_USERDATA, cast(int)(window));

			DXGI_SWAP_CHAIN_DESC scd;
			scd.BufferDesc.Width = 16;
			scd.BufferDesc.Height = 16;
			scd.BufferDesc.RefreshRate.Numerator = 60;
			scd.BufferDesc.RefreshRate.Denominator = 1;
			scd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
			scd.BufferDesc.ScanlineOrdering = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
			scd.BufferDesc.Scaling = DXGI_MODE_SCALING_UNSPECIFIED;
			scd.SampleDesc.Count = 1;
			scd.SampleDesc.Quality = 0;
			scd.BufferCount = 1;
			scd.BufferUsage = DXGI_USAGE_BACK_BUFFER | DXGI_USAGE_RENDER_TARGET_OUTPUT;
			scd.OutputWindow = hwnd;
			scd.Windowed = true;
			scd.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
			scd.Flags = 0;

			g_dxgiFactory.CreateSwapChain(Renderer_DX11.Get().GetD3DDevice(), &scd, &window.swapChain);
			return 0;
		}

		case WM_SIZE:
		{
			if (wParam == SIZE_MINIMIZED)
			{
				goto default;
			}

			Window* window = cast(Window*)(GetWindowLongPtr(hwnd, GWLP_USERDATA));

			const ushort width = LOWORD(wParam);
			const ushort height = HIWORD(lParam);

			DXGI_SWAP_CHAIN_DESC scd;
			window.swapChain.GetDesc(&scd);

			window.swapChain.ResizeBuffers(scd.BufferCount, width, height, DXGI_FORMAT_UNKNOWN, scd.Flags);
			return 0;
		}

		default:
		{
			return DefWindowProc(hwnd, msg, wParam, lParam);
		}
	}
}

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	try
    {
        Runtime.initialize();
        int result = DryMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
        Runtime.terminate();
		return result;
    }
    catch (Throwable e) 
    {
        MessageBoxA(null, e.msg.toStringz(), null, MB_ICONERROR);
		return 1;
    }
}

extern(Windows)
LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) nothrow
{
	try
	{
		return DryProc(hwnd, msg, wParam, lParam);
	}
	catch (Throwable e)
	{
		MessageBoxA(null, e.msg.toStringz(), null, MB_ICONERROR);
	}

	return 0;
}