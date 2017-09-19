module DryECS.components.transformcomponent;
import gl3n.linalg;

struct TransformComponent
{
    vec3 position = vec3(0,0,0);
    quat rotation = quat(0,0,0,1);
    vec3 scale = vec3(1,1,1);
    
    mat4 matWorld;
}