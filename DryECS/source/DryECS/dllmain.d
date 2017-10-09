module DryECS.dllmain;

import core.sys.windows.windows;
import core.sys.windows.dll;

import std.stdio;

version(Windows)
{

extern(Windows)
BOOL DllMain(
    HINSTANCE hInstance,
    DWORD ulReason,
    LPVOID pvReserved)
{
    final switch (ulReason)
    {
        case DLL_PROCESS_ATTACH:
            version(CRuntime_DigitalMars) _fcloseallp = null;
            break;
    }
    return true;
}

}