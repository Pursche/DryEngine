module DryECS.components.pointlight;
import DryECS.components.transform;
import DryECS.utils;
import gl3n.linalg;

@Component
@Requires!TransformComponent
struct PointLightComponent
{
    float temperature = 4000;
    float radius = 1.0;
}