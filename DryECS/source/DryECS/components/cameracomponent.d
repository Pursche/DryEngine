module DryECS.components.cameracomponent;
import gl3n.linalg;

struct CameraComponent
{
    float fov;
    mat4 matView;
    mat4 matProj;
    mat4 matViewProj;
}