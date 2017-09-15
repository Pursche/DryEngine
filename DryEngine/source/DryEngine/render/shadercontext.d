module DryEngine.render.shadercontext;

import DryEngine.render.types;
import DryEngine.render.material;

interface ShaderContext
{
    void SetResource(string name, RenderResourceHandle tex);
    void SetMaterials(const MaterialDef def, const void*[] materials);
}