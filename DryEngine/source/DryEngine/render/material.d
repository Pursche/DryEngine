module DryEngine.render.material;

import gl3n.linalg;

import std.typecons;

alias MaterialHandle = Typedef!(uint, 0xffffffff);

public struct Material
{
    public MaterialDef* def;
    public void* top;

    // todo: maybe auto-generate all of these?
    void SetFloat(string param, float value)
    {
        debug { assert(def.paramSize[param] == float.sizeof); }
        float* dst = cast(float*)(cast(char*)(top) + def.paramOffset[param]);
        *dst = value;
    }

    void SetFloat2(string param, vec2 value)
    {
        debug { assert(def.paramSize[param] == vec2.sizeof); }
        vec2* dst = cast(vec2*)(cast(char*)(top) + def.paramOffset[param]);
        *dst = value;
    }

    void SetFloat3(string param, vec3 value)
    {
        debug { assert(def.paramSize[param] == vec3.sizeof); }
        vec3* dst = cast(vec3*)(cast(char*)(top) + def.paramOffset[param]);
        *dst = value;
    }

    void SetFloat4(string param, vec4 value)
    {
        debug { assert(def.paramSize[param] == vec4.sizeof); }
        vec4* dst = cast(vec4*)(cast(char*)(top) + def.paramOffset[param]);
        *dst = value;
    }
}

public struct MaterialDef
{
    public size_t stride;
    public size_t[string] paramOffset;
    debug
    {
        public size_t[string] paramSize;
    }
}