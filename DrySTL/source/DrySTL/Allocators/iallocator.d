module DrySTL.Allocators.iallocator;

interface IAllocator
{
    void* AllocateRaw(size_t size, size_t alignment);
    T* Allocate(T)(size_t alignment);
    T* AllocateArray(T)(size_t count, size_t alignment);

    pragma(inline):
    void Free(void* ptr);

    void Reset();
    
}