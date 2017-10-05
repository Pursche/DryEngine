module DryECS.components.mesh;
import DryECS.components.transform;
import DryECS.utils;

import gl3n.linalg;

import DryEngine.render.mesh;
import DryEngine.render.material;

//todo: move
struct AxisAlignedBox
{
    vec2 min;
    vec2 max;
}

@Component
@Requires!TransformComponent
struct MeshComponent
{
    Mesh* mesh = null;
    Material* material = null;

    @Internal AxisAlignedBox aabb;
}