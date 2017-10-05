StructuredBuffer<Material> g_materials;

struct VSInput
{
};

struct PSOutput
{
    float4 color : SV_Target0;
};

float4 CalcLighting(float4 color, float3 normal, float roughness)
{

}

#define SET_VS_PS(__VSOutput, __VertexShader, __PixelShader)                   \
__VSOutput _VSMain(VSInput input, uint instanceID : SV_InstanceID)             \
{                                                                              \
    Material material = g_materials[instanceID];                               \
    return VertexShader(input, material);                                      \
}                                                                              \
PSOutput _PSMain(__VSOutput input, uint instanceID : SV_InstanceID)            \
{                                                                              \
    Material material = g_materials[instanceID];                               \
    return __PixelShader(input, material);                                     \
}