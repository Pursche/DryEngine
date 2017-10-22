module DryECS.components.transform;

public import DryECS.utils;
public import gl3n.linalg;


@Component(512)
struct TransformComponent
{
    vec3 position = vec3(0,0,0);
    quat rotation = quat(0,0,0,1);
    vec3 scale = vec3(1,1,1);

    @Internal mat4 matWorld;
}