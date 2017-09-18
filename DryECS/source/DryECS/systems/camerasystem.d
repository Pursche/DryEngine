module DryECS.systems.camerasystem;
import DryECS.components.transformcomponent;
import DryECS.components.cameracomponent;
import DryECS.utils;

import gl3n.linalg;

@In!(TransformComponent.matWorld)("matWorld")
@In!(CameraComponent.matView)("matView")
void UpdateViewMatrices(
    const mat4[] matWorld,
    mat4[] matView)
{
    for (size_t i = 0; i < matWorld.length; ++i)
    {
        matView[i] = matWorld[i].inverse();
    }
}

@In!(CameraComponent.fov)("fov")
@Out!(CameraComponent.matProj)("matView")
void UpdateProjectionMatrices(
    const float[] fov,
    mat4[] matProj)
{
    const uint width = 640;
    const uint height = 480;
    for (size_t i = 0; i < fov.length; ++i)
    {
        matProj[i] = mat4.perspective(width, height, fov[i], 0.1f, 500.0f);
    }
}

@In!(CameraComponent.matView)("matView")
@In!(CameraComponent.matProj)("matProj")
void CombineMatrices(
    const mat4[] matView,
    const mat4[] matProj,
    mat4[] matViewProj)
{
    for (size_t i = 0; i < matView.length; ++i)
    {
        matViewProj[i] = matView[i] * matProj[i];
    }
}
