module DryECS.systemshandler;
import std.stdio;

void LoadECS() // This and unload is just for having a fake init point at the moment, will be replaced when we can actually use a dll
{
    writeln("Loaded fake DLL");
    Init();
}

void UnloadECS()
{
    writeln("Unloaded fake DLL");
}

// Autogeneration begins

// These should be here no matter what components we have etc
import DryECS.utils;
import gl3n.linalg;

// This will probably have to be generated with a short python script or a D precompiler since this module doesn't know about the other modules at compiletime
import DryECS.components.transformcomponent;
import DryECS.systems.transformsystem;

// Do this for each component found, 32 is how many we can max have
SOA!(TransformComponent, 32) transformComponents;

void Init() // Will be auto generated
{
    // TransformComponents need to be initialized since the SOA template inits them as NaN, do this for each component found
    for(int i = 0; i < transformComponents.position.length; i++)
    {
        transformComponents.position = vec3(0,0,0);
    }
    for(int i = 0; i < transformComponents.rotation.length; i++)
    {
        transformComponents.rotation = quat(0,0,0,1);
    }
    for(int i = 0; i < transformComponents.scale.length; i++)
    {
        transformComponents.scale = vec3(1,1,1);
    }
}

void Start() // This will be auto generated
{
    DryECS.systems.transformsystem.Start();
}

void Update(float deltaTime) // Will be auto generated
{
    DryECS.systems.transformsystem.Update(transformComponents.position, transformComponents.rotation, transformComponents.scale, transformComponents.matWorld);
}