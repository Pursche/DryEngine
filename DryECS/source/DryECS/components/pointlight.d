module DryECS.components.pointlight;
import DryECS.utils;
import gl3n.linalg;

@Component
struct PointLightComponent
{
    vec4 color;
    float radius;
}