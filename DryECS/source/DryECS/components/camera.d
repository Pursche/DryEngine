module DryECS.components.camera;
import DryECS.utils;
import gl3n.linalg;

@Component
struct CameraComponent
{
    float fov = 0.6f;

    mat4 matView;
    mat4 matProj;
    mat4 matViewProj;
}