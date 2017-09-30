module DryGame.ecs.ecswrapper;

import std.stdio;
import std.string;
import std.exception;

version(linux)
{
import DryGame.ecs.libutil;

Library lib;

public void LoadECS()
{
    UnloadECS();

    printf("Loading ECS... \n");
    version(linux)
    {
        lib = enforce(loadLib("./libdryecs.so"));//todo
    }
    version(Windows)
    {
        lib = enforce(loadLib("dryecs"));
    }

    printf("Done\n");
    
    auto Init = lib.loadFunc!(void function(), "DryECS.systemshandler.Init");
    Update = lib.loadFunc!(typeof(Update), "DryECS.systemshandler.Update");
    CreateEntity = lib.loadFunc!(typeof(CreateEntity), "DryECS.systemshandler.CreateEntity");

    writeln(Init);
    writeln(Update);
    writeln(CreateEntity);

    Init();
}

public void UnloadECS()
{
    if (lib)
    {
        writeln("Unloading ECS...");
        unloadLib(lib);
        writeln("Done");
        lib = null;
    }
}

public void function(float) Update;
public size_t function(size_t) CreateEntity;

}

version(Windows)
{

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

}