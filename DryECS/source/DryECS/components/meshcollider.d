module DryECS.components.meshcollider;
import DryECS.components.transform;
import DryECS.utils;

alias void MeshCollider;//todo

@Component
@Requires!TransformComponent
struct MeshColliderComponent
{
    MeshCollider* collider;

    static void Init(MeshCollider*[] collider)
    {
        
    }
}