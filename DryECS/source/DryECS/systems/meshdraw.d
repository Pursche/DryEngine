module DryECS.systems.meshdraw;
import DryECS.utils;

import DryECS.components.transform;
import DryECS.components.mesh;

import gl3n.linalg;

/*
@System
@In!(TransformComponent.matWorld)("matWorld")
@In!(MeshComponent.mesh)("meshes")
@In!(MeshComponent.material)("materials")
void DrawMeshes(
    const mat4[] matWorld,
    const void*[] meshes,
    const void*[] materials)
{
    
}*/