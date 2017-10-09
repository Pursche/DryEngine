module DryGame.ecs.ecswrapper;

import std.stdio;
import std.string;
import std.exception;

/*
import DryGame.ecs.libutil;

Library lib;

public void LoadECS()
{
    UnloadECS();

    writeln("Loading ECS Library...");
    version(linux)
    {
        lib = enforce(loadLib("./libdryecs.so"));
    }
    version(Windows)
    {
        lib = enforce(loadLib("dryecs.dll"));
    }

    writeln("Done");
    
    auto Init = lib.loadFunc!(void function(), "DryECS.systemshandler.Init");
    Update = lib.loadFunc!(typeof(Update), "DryECS.systemshandler.Update");
    CreateEntity = lib.loadFunc!(typeof(CreateEntity), "DryECS.systemshandler.CreateEntity");

    writefln("Init = %X", Init);
    writefln("Update = %X", Update);
    writefln("CreateEntity = %X", CreateEntity);

    Init();

    import core.sys.windows.windows;
    import std.string;
    string msg = "fisk";
    DWORD charsWritten;
    WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), msg.toStringz(), cast(uint)msg.length, &charsWritten, null);
}

public void UnloadECS()
{
    if (lib)
    {
        writeln("Unloading ECS Library...");
        unloadLib(lib);
        writeln("Done");
        lib = null;
    }
}

public void function(float) Update;
public size_t function(size_t) CreateEntity;
*/

import DryECS.systemshandler;

public void LoadECS()
{
    DryECS.systemshandler.Init();
}

public void UnloadECS()
{
}

public void Update(float dt)
{
    DryECS.systemshandler.Update(dt);
}

public size_t CreateEntity(size_t key)
{
    return DryECS.systemshandler.CreateEntity(key);
}
