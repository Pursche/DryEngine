module DryECS.components.camera;
import DryECS.components.transform;
import DryECS.utils;
import gl3n.linalg;

@Component
@Requires!TransformComponent
struct CameraComponent
{
    float fov = 75;

    @Internal mat4 matView;
    @Internal mat4 matProj;
    @Internal mat4 matViewProj;
}