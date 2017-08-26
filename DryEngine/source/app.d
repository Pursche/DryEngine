import std.stdio;

import DrySTL.Allocators.linearallocator;

void main()
{
	LinearAllocator allocator = new LinearAllocator(512);

	writeln("Edit source/app.d to start your project.");
}
