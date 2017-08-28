module render.opengl.renderdispatch_gl;

import render.renderdispatch;
import render.types;
import render.commands;

import opengl.gl4;

class RenderDispatchContext_GL : RenderDispatchContext
{
    override public void Draw(Cmd_Draw* cmd)
    {
        GLenum mode;
        final switch (cmd.topology)
        {
            case PrimitiveTopology.PointList: mode = GL_POINTS; break;
            case PrimitiveTopology.LineList: mode = GL_LINES; break;
            case PrimitiveTopology.LineStrip: mode = GL_LINE_STRIP; break;
            case PrimitiveTopology.TriangleList: mode = GL_TRIANGLES; break;
            case PrimitiveTopology.TriangleStrip: mode = GL_TRIANGLE_STRIP; break;
        }

        GLuint indexBuffer = 0;//todo
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);

        const uint indexSize = 4;
        

        glDrawElements(mode, cmd.indexCount, GL_UNSIGNED_INT, cast(void*)(cmd.indexOffset * indexSize));
    }
    
    override public void Dispatch(Cmd_Dispatch* cmd)
    {
        
        glDispatchCompute(cmd.groupCountX, cmd.groupCountY, cmd.groupCountZ);
    }

    override public void UpdateTexture1D(Cmd_UpdateTexture1D* cmd)
    {
        GLuint texture = 0;
        glBindTexture(GL_TEXTURE_1D, texture);
        
        int width, format;
        glGetTexLevelParameteriv(GL_TEXTURE_1D, cmd.mipSlice, GL_TEXTURE_WIDTH, &width);
        glGetTexLevelParameteriv(GL_TEXTURE_1D, cmd.mipSlice, GL_TEXTURE_INTERNAL_FORMAT, &format);
        glTexSubImage1D(GL_TEXTURE_1D, cmd.mipSlice, 0, width, format, GL_UNSIGNED_BYTE, cmd.data);
    }

    override public void UpdateTexture1DArray(Cmd_UpdateTexture1DArray* cmd)
    {
        GLuint texture = 0;
        glBindTexture(GL_TEXTURE_1D_ARRAY, texture);
        
        int width, format;
        glGetTexLevelParameteriv(GL_TEXTURE_1D_ARRAY, cmd.mipSlice, GL_TEXTURE_WIDTH, &width);
        glGetTexLevelParameteriv(GL_TEXTURE_1D_ARRAY, cmd.mipSlice, GL_TEXTURE_INTERNAL_FORMAT, &format);
        glTexSubImage2D(GL_TEXTURE_1D, cmd.mipSlice, 0, cmd.arraySlice, width, 1, format, GL_UNSIGNED_BYTE, cmd.data);
    }

    override public void UpdateTexture2D(Cmd_UpdateTexture2D* cmd)
    {
        GLuint texture = 0;
        glBindTexture(GL_TEXTURE_2D, texture);
        
        int width, height, format;
        glGetTexLevelParameteriv(GL_TEXTURE_2D, cmd.mipSlice, GL_TEXTURE_WIDTH, &width);
        glGetTexLevelParameteriv(GL_TEXTURE_2D, cmd.mipSlice, GL_TEXTURE_HEIGHT, &height);
        glGetTexLevelParameteriv(GL_TEXTURE_2D, cmd.mipSlice, GL_TEXTURE_INTERNAL_FORMAT, &format);
        glTexSubImage2D(GL_TEXTURE_2D, cmd.mipSlice, 0, 0, width, height, format, GL_UNSIGNED_BYTE, cmd.data);
    }

    override public void UpdateTexture2DArray(Cmd_UpdateTexture2DArray* cmd)
    {
        GLuint texture = 0;
        glBindTexture(GL_TEXTURE_2D_ARRAY, texture);
        
        int width, height, format;
        glGetTexLevelParameteriv(GL_TEXTURE_2D_ARRAY, cmd.mipSlice, GL_TEXTURE_WIDTH, &width);
        glGetTexLevelParameteriv(GL_TEXTURE_2D_ARRAY, cmd.mipSlice, GL_TEXTURE_HEIGHT, &height);
        glGetTexLevelParameteriv(GL_TEXTURE_2D_ARRAY, cmd.mipSlice, GL_TEXTURE_INTERNAL_FORMAT, &format);
        glTexSubImage3D(GL_TEXTURE_2D_ARRAY, cmd.mipSlice, 0, 0, cmd.arraySlice, width, height, 1, format, GL_UNSIGNED_BYTE, cmd.data);
    }

    override public void UpdateTexture3D(Cmd_UpdateTexture3D* cmd)
    {
        GLuint texture = 0;
        glBindTexture(GL_TEXTURE_3D, texture);
        
        int width, height, depth, format;
        glGetTexLevelParameteriv(GL_TEXTURE_3D, cmd.mipSlice, GL_TEXTURE_WIDTH, &width);
        glGetTexLevelParameteriv(GL_TEXTURE_3D, cmd.mipSlice, GL_TEXTURE_HEIGHT, &height);
        glGetTexLevelParameteriv(GL_TEXTURE_3D, cmd.mipSlice, GL_TEXTURE_DEPTH, &depth);
        glGetTexLevelParameteriv(GL_TEXTURE_3D, cmd.mipSlice, GL_TEXTURE_INTERNAL_FORMAT, &format);
        glTexSubImage3D(GL_TEXTURE_3D, cmd.mipSlice, 0, 0, 0, width, height, depth, format, GL_UNSIGNED_BYTE, cmd.data);
    }
}
