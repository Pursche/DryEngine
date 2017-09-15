module DryEngine.core.system;

import DryEngine.render.mesh;

import gl3n.linalg;

class System
{
    Mesh _triangle;

    public this(string[] args)
    {
        const vec3[] pos = [
            vec3( 0.0f, -1.0f,  0.0f ),
            vec3(-1.0f,  1.0f,  0.0f ),
            vec3( 1.0f,  1.0f,  0.0f ),
        ];
        const uint[] indices = [
            0, 1, 2,
        ];
        _triangle = new Mesh(pos, indices);
    }

    public void Update()
    {
        
    }
}