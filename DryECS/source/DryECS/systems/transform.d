module DryECS.systems.transform;
import DryECS.components.transform;
import DryECS.utils;
import gl3n.linalg;

@System()
@In!(TransformComponent.position)("positions")
@In!(TransformComponent.rotation)("rotations")
@In!(TransformComponent.scale)("scales")
@Out!(TransformComponent.matWorld)("worldMatrices")
void UpdateTransform(const vec3[] positions, 
    const quat[] rotations, 
    const vec3[] scales,
    mat4[] worldMatrices) pure
{
    for (size_t i = 0; i < positions.length; ++i)
    {
        worldMatrices[i] = Transform(positions[i], rotations[i], scales[i]);
    }
}

mat4 Transform(vec3 pos, quat rot, vec3 scale) pure
{
    return mat4.scaling(scale.x, scale.y, scale.z) * mat4.translation(pos);
}
