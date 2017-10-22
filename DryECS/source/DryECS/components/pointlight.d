module DryECS.components.pointlight;

public import DryECS.components.transform;
public import DryECS.utils;
public import gl3n.linalg;

@Component(128)
@Requires!TransformComponent
struct PointLightComponent
{
    float temperature = 4000;
    float radius = 1.0;
}