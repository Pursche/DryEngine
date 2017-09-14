module DryEngine.render.opengl.renderer_gl;

import DryEngine.render.renderer;
import DryEngine.render.types;
import opengl.gl4;

class Renderer_GL : Renderer
{
    private GLuint[] _resources;

    public this()
    {
        _resources = new GLuint[1024];
    }

    override protected bool InitTexture(RenderResourceHandle handle, const RenderTextureDesc desc)
    {
        GLuint tex;
        glGenTextures(1, &tex);

        GLenum internalFormat;
        GLenum format;
        GLenum type;

        final switch (desc.type)
        {
            case RenderTextureType.Texture1D:
                glBindTexture(GL_TEXTURE_1D, tex);
                glTexImage1D(GL_TEXTURE_1D, 0, internalFormat, desc.width, 0, format, type, desc.data);
                break;
            case RenderTextureType.Texture1DArray:
                glBindTexture(GL_TEXTURE_1D_ARRAY, tex);
                glTexImage2D(GL_TEXTURE_1D_ARRAY, 0, internalFormat, desc.width, desc.arraySlices, 0, format, type, desc.data);
                break;
            case RenderTextureType.Texture2D:
                glBindTexture(GL_TEXTURE_2D, tex);
                glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, desc.width, desc.height, 0, format, type, desc.data);
                break;
            case RenderTextureType.Texture2DArray:
                glBindTexture(GL_TEXTURE_2D_ARRAY, tex);
                glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, internalFormat, desc.width, desc.height, desc.arraySlices, 0, format, type, desc.data);
                break;
            case RenderTextureType.Texture3D:
                glBindTexture(GL_TEXTURE_3D, tex);
                glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, internalFormat, desc.width, desc.height, desc.depth, 0, format, type, desc.data);
                break;
        }

        _resources[cast(size_t)(handle)] = tex;
        return true;
    }

    override protected bool InitBuffer(RenderResourceHandle handle, const RenderBufferDesc desc)
    {
        GLuint buffer;
        glGenBuffers(1, &buffer);

        GLenum usage;
        if (desc.usage == RenderResourceUsage.Default)
        {
            usage = GL_STREAM_DRAW;
        }
        else if (desc.usage == RenderResourceUsage.Immutable)
        {
            usage = GL_STATIC_DRAW;
        }
        else if (desc.usage == RenderResourceUsage.Dynamic)
        {
            usage = GL_DYNAMIC_DRAW;
        }

        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glBufferData(GL_ARRAY_BUFFER, desc.size, desc.data, usage);

        _resources[cast(size_t)(handle)] = buffer;
        return true;
    }
}
