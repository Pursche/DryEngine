import std.stdio;

import DrySTL.Allocators.linearallocator;
import ecs.ecswrapper;

import core.runtime;

void main()
{
	Runtime.initialize();
	LinearAllocator allocator = new LinearAllocator(512);

	LoadECS();
	scope(exit) UnloadECS();
	LoadECS();
}
