module DryECS.components.meshcollider;

public import DryECS.components.transform;
public import DryECS.utils;

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