module DryECS.components.cameracomponent;
import gl3n.linalg;

struct CameraComponent
{
    float fov = 0.6f;

    mat4 matView;
    mat4 matProj;
    mat4 matViewProj;
}