module DryEngine.ecs.ecswrapper;

import DryEngine.ecs.libutil;
import std.stdio;
import std.string;
import std.exception;

/*
Library lib;

public void LoadECS()
{
    /*
    UnloadECS();

    // Load new DLL
    printf("Loading library... \n");
    lib = enforce(loadLib("dryecs"));
    if (lib is null)
        printf("Failed\n");
    else
    {
        printf("Done\n");

        import core.sys.windows.windows;
        import core.demangle;
        import core.runtime;
        writeln("Mangled: ", mangle!(void function())("dryecs.main.Start"));

        HMODULE h = cast(HMODULE) Runtime.loadLibrary("dryecs.dll");
        void* test = GetProcAddress(h, toStringz("_D6dryecs4main5StartFZv"));

        writeln(test);

        void function() testFunc = cast(void function()) test;
        testFunc();
        
        /*
        Start = cast(void function()) GetProcAddress(lib._handle, toStringz("_D6dryecs4main5StartFZv"));
        //auto test = lib.loadFunc!(void function(), "dryecs.main.Start")();      
        auto test2 = lib.loadFunc!(void function(float), "dryecs.main.Update")();

        writeln("Calling 1");
        writeln(Start == null);
        Start();
        writeln("Calling 2");
        test2(2.5f);
   }
}

public void UnloadECS()
{
    if (!(lib is null))
    {
        // Unload loaded dll  
        writeln("Unloading library...");
        lib.unloadLib();

        
        writeln("Done");  
        lib = null;
    }
    writeln("Test");
}

void function() Start;
*/


import DryECS.systemshandler;
void LoadECS()
{
    DryECS.systemshandler.LoadECS();
}

void UnloadECS()
{
    DryECS.systemshandler.UnloadECS();
}

void Start()
{
    DryECS.systemshandler.Start();
}

void Update(float deltaTime)
{
    DryECS.systemshandler.Update(deltaTime);
}