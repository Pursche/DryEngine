import std.stdio;

import DrySTL.Allocators.linearallocator;
import render.renderer;
import render.opengl.renderer_gl;

void main()
{
	LinearAllocator allocator = new LinearAllocator(512);

	Renderer_GL renderer = new Renderer_GL();
	
}
