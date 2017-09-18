/*import std.stdio;

import DrySTL.Allocators.linearallocator;
import ecs.ecswrapper;

import core.runtime;

void main()
{
	Runtime.initialize();
	LinearAllocator allocator = new LinearAllocator(512);

	ecs.ecswrapper.LoadECS();
	ecs.ecswrapper.Start();
	ecs.ecswrapper.Update(0.5f);
	ecs.ecswrapper.UnloadECS();
}
*/