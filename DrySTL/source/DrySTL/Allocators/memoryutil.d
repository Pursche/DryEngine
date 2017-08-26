module DrySTL.Allocators.memoryutil;

import core.atomic;

static import std.traits;
alias isArray = std.traits.isArray;

static import std.typecons;
alias TypeTuple = std.meta.AliasSeq;

enum CTOR = "__ctor";
enum DTOR = "__dtor";

template SizeOf(T) 
{
    static assert(!is(T : V[K], V, K), "Cannot figure out the size of an assocative array.");

    static if (is(T == class))
        enum size_t SizeOf = __traits(classInstanceSize, T);
    else
        enum size_t SizeOf = T.sizeof;
}

template DimOf(T) 
{
    static assert(!is(T : V[K], V, K), "Cannot figure out the dimension of an assocative array.");

    static if (is(T : U[], U))
        enum size_t DimOf = 1 + DimOf!(U);
    else static if (is(T : U*, U))
        enum size_t DimOf = 1 + DimOf!(U);
    else
        enum size_t DimOf = 0;
}

template BasicTypeOf(T) 
{
    static assert(!is(T : V[K], V, K), "Cannot figure out the basic type of an assocative array.");

    static if (is(T : U[], U))
        alias BasicTypeOf = BasicTypeOf!(U);
    else
        alias BasicTypeOf = T;
}

template NextTypeOf(T) 
{
    static assert(!is(T : V[K], V, K), "Cannot figure out the next type of an assocative array.");

    static if (is(T : U[], U))
        alias NextTypeOf = U;
    else
        alias NextTypeOf = T;
}

enum TypeOfClass : ubyte 
{
    AsClass,
    AsVoid
}

template TypeOf(T, TypeOfClass toc = TypeOfClass.AsClass) 
{
    static assert(!is(T : V[K], V, K), "Cannot figure out the type of an assocative array.");

    static if (isArray!(T)) 
    {
        enum size_t DIM = DimOf!(T);
        static assert(DIM < 5, "Too high dimension");

        alias Base = BasicTypeOf!(T);
        static if (is(Base == class))
            alias Bases = TypeTuple!(void**, void**, void***, void****, void*****);
        else
            alias Bases = TypeTuple!(Base*, Base*, Base**, Base***, Base****);

        alias TypeOf = Bases[DIM];
    } 
    else static if (is(T == class)) 
    {
        static if (toc == TypeOfClass.AsVoid)
            alias TypeOf = void*;
        else
            alias TypeOf = T;
    } 
    else
        alias TypeOf = T*;
}

auto Emplace(T, Args...)(void[] buf, auto ref Args args) if (is(T == class) || is(T == struct)) 
{
    enum size_t SIZE = SizeOf!(T);
    assert(buf.length == SIZE, "No enough space in buf");
    alias Type = TypeOf!(T);

    static if (is(T == class)) 
    {
        buf[] = typeid(T).init[];
        debug(m3) printf("Emplace class %s\n", &T.stringof[0]);
    }

    Type tp = cast(Type) buf.ptr;

    static if (is(T == struct)) 
    {
        *tp = T.init;
        debug(m3) printf("Emplace struct %s\n", &T.stringof[0]);
    }

    static if (args.length != 0) 
    {
        static assert(__traits(hasMember, T, CTOR), "No CTor for type " ~ T.stringof);
        tp.__ctor(args);
    }

    return tp;
}

T GetAndAdd(T)(T* variable, size_t add)
{
    return (*variable).atomicOp!"+="(add);
}

size_t AlignAs(size_t size, size_t alignment)
{
    if(alignment == 0)  
    {  
        return size;  
    }  

    size_t remainder = size % alignment; 
    if (remainder == 0)
    {
        return size; 
    }

    return size + alignment - remainder;
}