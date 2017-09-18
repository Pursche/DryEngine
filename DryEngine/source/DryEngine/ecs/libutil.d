module DryEngine.ecs.libutil;
import core.runtime;
import core.demangle;
import std.string;

struct Library
{
    void* _handle;
    alias _handle this;

    version(linux)
    {
        T loadFunc(T:FT*, FT)(string fqn) if(is(FT==function))
        {
            immutable m = mangle!FT(fqn);
            return cast(T) dlsym(_handle, toStringz(m));
        }

        T loadFunc(T:FT*, string fqn, FT)() if(is(FT==function))
        {
            static immutable m = mangle!FT(fqn);
            return cast(T) dlsym(_handle, m.ptr);
        }

        T* loadSym(T)(string fqn)
        {
            immutable m = mangle!T(fqn);
            return cast(T*) dlsym(_handle, toStringz(m));
        }

        T* loadSym(T, string fqn)()
        {
            static immutable m = mangle!T(fqn);
            return cast(T*) dlsym(_handle, m.ptr);
        }
    }

    version(Windows)
    {
        import core.sys.windows.windows;

        T loadFunc(T:FT*, string fqn, FT)() if(is(FT==function))
        {
            static immutable m = mangle!FT(fqn);
            return cast(T) GetProcAddress(_handle, m.ptr);
        }

        T* loadSym(T)(string fqn)
        {
            immutable m = mangle!T(fqn);
            return cast(T*) GetProcAddress(_handle, toStringz(m));
        }
        
        T* loadSym(T, string fqn)()
        {
            static immutable m = mangle!T(fqn);
            return cast(T*) GetProcAddress(_handle, m.ptr);
        }
    }
}

Library loadLib(string path)
{
    return Library(Runtime.loadLibrary(path));
}

void unloadLib(ref Library lib)
{
    Runtime.unloadLibrary(lib._handle);
    lib._handle=null;
}

