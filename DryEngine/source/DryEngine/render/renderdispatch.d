module DryEngine.render.renderdispatch;

import DryEngine.render.commands;

interface RenderDispatchContext
{
    public void Draw(Cmd_Draw* cmd);
    public void Dispatch(Cmd_Dispatch* cmd);
    public void UpdateTexture1D(Cmd_UpdateTexture1D* cmd);
    public void UpdateTexture1DArray(Cmd_UpdateTexture1DArray* cmd);
    public void UpdateTexture2D(Cmd_UpdateTexture2D* cmd);
    public void UpdateTexture2DArray(Cmd_UpdateTexture2DArray* cmd);
    public void UpdateTexture3D(Cmd_UpdateTexture3D* cmd);
}


