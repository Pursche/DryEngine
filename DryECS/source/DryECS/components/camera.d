module DryECS.components.camera;

public import DryECS.components.transform;
public import DryECS.utils;
public import gl3n.linalg;

@Component
@Requires!TransformComponent
struct CameraComponent
{
    float fov = 75;

    @Internal mat4 matView;
    @Internal mat4 matProj;
    @Internal mat4 matViewProj;
}