module DryECS.systemshandler;
import DryECS.componentstore;
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
import DryECS.components.cameracomponent;
import DryECS.systems.transformsystem;
import DryECS.systems.camerasystem;

enum transformComponentID = (1 << 0);
enum cameraComponentID = (1 << 1);

// Do this for each component found, 32 is how many we can max have
// 1 is how many unique systems (in terms of key) use this component
ComponentStore!(TransformComponent, transformComponentID) transformComponents;
ComponentStore!(CameraComponent, cameraComponentID) cameraComponents;

void Init() // Will be auto generated
{
    transformComponents = new ComponentStore!(TransformComponent, transformComponentID)(64);
    cameraComponents = new ComponentStore!(CameraComponent, cameraComponentID)(32);
}

void Start() // This will be auto generated
{
}

void Update(float deltaTime) // Will be auto generated
{
    transformComponents.Verify();
    cameraComponents.Verify();

    {
        enum dependencies = 0;
        auto out_matWorld = transformComponents.Write!(dependencies, mat4, "matWorld"); // zero overhead
        DryECS.systems.transformsystem.Update(
            transformComponents.Read!(dependencies, vec3, "position"), // zero overhead
            transformComponents.Read!(dependencies, quat, "rotation"), // zero overhead
            transformComponents.Read!(dependencies, vec3, "scale"), // zero overhead
            out_matWorld);
        transformComponents.Feedback!(dependencies, "matWorld")(out_matWorld); // zero overhead
    }

    {
        enum dependencies = transformComponentID;
        auto out_matView = cameraComponents.Write!(dependencies, mat4, "matView");
        DryECS.systems.camerasystem.UpdateViewMatrices(
            transformComponents.Read!(dependencies, mat4, "matWorld"),
            out_matView);
        cameraComponents.Feedback!(dependencies, "matView")(out_matView);
    }

    {
        enum dependencies = 0;
        auto out_matProj = cameraComponents.Write!(dependencies, mat4, "matProj"); // zero overhead
        DryECS.systems.camerasystem.UpdateProjectionMatrices(
            cameraComponents.Read!(dependencies, float, "fov"), // zero overhead
            out_matProj);
        cameraComponents.Feedback!(dependencies, "matProj")(out_matProj); // zero overhead
    }

    {
        enum dependencies = 0;
        auto out_matViewProj = cameraComponents.Write!(dependencies, mat4, "matViewProj"); // zero overhead
        DryECS.systems.camerasystem.CombineMatrices(
            cameraComponents.Read!(dependencies, mat4, "matView"), // zero overhead
            cameraComponents.Read!(dependencies, mat4, "matProj"), // zero overhead
            out_matViewProj);
        cameraComponents.Feedback!(dependencies, "matViewProj")(out_matViewProj); // zero overhead
    }
}