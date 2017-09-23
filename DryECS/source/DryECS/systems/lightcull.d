module DryECS.systems.lightcull;
import DryECS.utils;

import DryECS.components.transform;
import DryECS.components.camera;
import DryECS.components.pointlight;

import gl3n.linalg;

@In!(TransformComponent.position)("lightPos")
@In!(PointLightComponent.radius)("lightRadius")
@In!(CameraComponent.matViewProj)("matViewProj")
void Cull(
    const vec3[] lightPos, 
    const float[] lightRadius,
    const mat4[] matViewProj)
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