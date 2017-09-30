module DryECS.systems.lightcull;
import DryECS.utils;

import DryECS.components.transform;
import DryECS.components.camera;
import DryECS.components.pointlight;

import gl3n.linalg;

@In!(TransformComponent.position)("lightPos", 0)
@In!(PointLightComponent.radius)("lightRadius", 0)
@In!(CameraComponent.matViewProj)("matViewProj", 1)
void Cull(
    const vec3[] lightPos, 
    const float[] lightRadius,
    const mat4[] matViewProj) pure
{
    const size_t cameraCount = matViewProj.length;
    const size_t lightCount = lightPos.length;

    for (size_t cameraIt = 0; cameraIt < cameraCount; ++cameraIt)
    {
        for (size_t lightIt = 0; lightIt < lightCount; ++lightIt)
        {
            // cull
        }
    }
}