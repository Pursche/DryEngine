module DryECS.systems.camera;
import DryECS.components.transform;
import DryECS.components.camera;
import DryECS.utils;

import gl3n.linalg;

@System()
@In!(TransformComponent.matWorld)("matWorld")
@Out!(CameraComponent.matView)("matView")
void UpdateViewMatrices(
    const mat4[] matWorld,
    mat4[] matView) pure
{
    for (size_t i = 0; i < matWorld.length; ++i)
    {
        matView[i] = matWorld[i].inverse();
    }
}

@System()
@In!(CameraComponent.fov)("fov")
@Out!(CameraComponent.matProj)("matProj")
void UpdateProjectionMatrices(
    const float[] fov,
    mat4[] matProj) pure
{
    const uint width = 640;
    const uint height = 480;
    for (size_t i = 0; i < fov.length; ++i)
    {
        matProj[i] = mat4.perspective(width, height, fov[i], 0.1f, 500.0f);
    }
}

@System()
@In!(CameraComponent.matView)("matView")
@In!(CameraComponent.matProj)("matProj")
@Out!(CameraComponent.matViewProj)("matViewProj")
void CombineMatrices(
    const mat4[] matView,
    const mat4[] matProj,
    mat4[] matViewProj) pure
{
    for (size_t i = 0; i < matView.length; ++i)
    {
        matViewProj[i] = matView[i] * matProj[i];
    }
}
