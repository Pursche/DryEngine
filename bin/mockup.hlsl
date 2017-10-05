#include "common.hlsl"

struct Material
{
    float4 diffuseColor;
};

struct PSInput
{

};

PSInput VertexShader(VSInput vertex, Material material)
{
    PSInput output;

    return output;
}

PSOutput PixelShader(PSInput vertex, Material material)
{
    return CalcFinalPixelOutput();
}

// Temporary (?)
SET_VS_PS(VSOutput, VertexShader, PixelShader);
