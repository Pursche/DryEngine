module DryECS.components.meshcollider;

public import DryECS.components.transform;
public import DryECS.utils;

//alias void MeshCollider;//todo // This breaks ECS code generation

@Component(128)
@Requires!TransformComponent
struct MeshColliderComponent
{
    void* collider;

    static void Init(void*[] collider)
    {
        
    }
}