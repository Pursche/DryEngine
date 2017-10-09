module DryECS.components.mesh;

public import DryECS.components.transform;
public import DryECS.utils;

public import gl3n.linalg;

public import DryEngine.render.mesh;
public import DryEngine.render.material;

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
    MeshHandle mesh = 0xffffffff;
    MaterialHandle material = 0xffffffff;

    @Internal AxisAlignedBox aabb;
}