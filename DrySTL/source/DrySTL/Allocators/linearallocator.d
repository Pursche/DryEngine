module DrySTL.Allocators.linearallocator;

import core.stdc.stdlib;
import core.atomic;
import std.stdio;
import std.conv;
import DrySTL.Allocators.iallocator;
import DrySTL.Allocators.memoryutil;

class LinearAllocator : IAllocator
{
    // Data storage
    const size_t _capacity;
	shared size_t _offset;
	void* _data;
    Dtor[] _dtors;

    alias void delegate() Dtor;

    this(size_t capacity)
    {
        _offset = 0;
        _capacity = capacity;
        _data = malloc(capacity);
    }

    ~this()
    {
        
    }

    public void* AllocateRaw(size_t size, size_t alignment)
    {
        writeln("Allocating ", size, " aligned to  ", alignment);
		size_t alignedSize = AlignAs(size, alignment);
        size_t offset = GetAndAdd(&_offset, alignedSize);
        writeln("Offset: ", offset);
		assert(offset < _capacity, "Linear allocator out of memory, after allocating " ~ to!string(alignedSize) ~ " " ~ Print());
		return (&_data + offset);
    }

    auto Allocate(T, Args...)(size_t alignment, auto ref Args args) if (is(T == class) || is(T == struct)) // Classes and structs
    {
        alias Base = BasicTypeOf!(T);
        enum size_t SIZE = SizeOf!(T);
        
        writeln("Allocating ", SIZE, " aligned to  ", alignment);
		size_t alignedSize = AlignAs(SIZE, alignment);
        size_t offset = GetAndAdd(&_offset, alignedSize);
		assert(offset < _capacity, "Linear allocator out of memory, after allocating " ~ to!string(alignedSize) ~ " " ~ Print());

        void* p = &_data + offset;

        auto newObject = Emplace!(T)(p[0 .. SIZE], args);

        static if (is(T == class)) 
        {
            if (typeid(newObject).destructor != null)
            {
                writeln("Added dtor");
                Dtor dtor;
                dtor.ptr = &newObject;
                void function() funcPtr = cast(void function()) typeid(newObject).destructor;
                dtor.funcptr = funcPtr;
                _dtors ~= dtor;
            }
            else
            {
                writeln("Dtor was null");
            }
        }

		return newObject;
    }

    //@nogc
    auto Allocate(T, Args...)(size_t alignment, auto ref Args args) if (!isArray!(T) && !is(T == class) && !is(T == struct)) // Types
    {
        enum size_t SIZE = SizeOf!(T);

        writeln("Allocating ", SIZE, " aligned to  ", alignment);
        size_t alignedSize = AlignAs(SIZE, alignment);
        size_t offset = GetAndAdd(&_offset, alignedSize);
		assert(offset < _capacity, "Linear allocator out of memory, after allocating " ~ to!string(alignedSize) ~ " " ~ Print());

        T* p = cast(T*)(&_data + offset);

        static if (!is(T == void)) 
        {
            static if (args.length == 0)
                *p = T.init;
            else 
            {
                static assert(args.length == 1, "Too many parameters!");
                *p = args[0];
            }
        } 
        else 
        {
            static assert(args.length == 0, "void cannot have arguments");
        }

        return p;
    }

    T Allocate(T)(size_t count, size_t alignment) if (isArray!(T)) 
    {
        alias Base = BasicTypeOf!(T);
        alias Next = NextTypeOf!(T);
        enum size_t SIZE = SizeOf!(Next);
        size_t arraySize = SIZE * count;

        writeln("Allocating ", arraySize, " aligned to  ", alignment);
		size_t alignedSize = AlignAs(arraySize, alignment);
        size_t offset = GetAndAdd(&_offset, alignedSize);
		assert(offset < _capacity, "Linear allocator out of memory, after allocating " ~ to!string(alignedSize) ~ " " ~ Print());

        void* p = &_data + offset;

        static if (is(Base == class)) 
        {
            alias Type = TypeOf!(T);

            T arr = cast(T) (cast(Type) p)[0 .. count];
        }  else
            T arr = (cast(Next*) p)[0 .. count];

        static if (!is(Base == void))
            arr[0 .. count] = Next.init;

        return arr;
    }

    public void Free(void* ptr)
    {

    }

    public void Reset()
    {
        foreach(Dtor dtor ; _dtors)
        {
            writeln("Something destroyed");
            dtor();
        }
        _dtors = null;
        _offset = 0;
    }

    public string Print()
    {
        return "Memory usage: " ~ to!string(_offset) ~ "/" ~ to!string(_capacity) ~ " " ~ to!string((cast(float)_offset / cast(float)_capacity) * 100.0f)  ~ "%";
    }
}