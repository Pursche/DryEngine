module DryECS.components.transform;
import DryECS.utils;
import gl3n.linalg;


@Component
struct TransformComponent
{
    vec3 position = vec3(0,0,0);
    quat rotation = quat(0,0,0,1);
    vec3 scale = vec3(1,1,1);

    @Internal mat4 matWorld;
}