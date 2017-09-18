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

    {
        enum key = transformComponentID;
        DryECS.systems.transformsystem.Update(
            transformComponents.Get!(key, vec3, "position"), 
            transformComponents.Get!(key, quat, "rotation"), 
            transformComponents.Get!(key, vec3, "scale"), 
            transformComponents.Set!(key, mat4, "matWorld"));
    }

    {
        enum key = transformComponentID | cameraComponentID;
        auto matView = cameraComponents.Set!(key, mat4, "matView");
        DryECS.systems.camerasystem.UpdateViewMatrices(
            transformComponents.Get!(key, mat4, "matWorld"),
            matView);
        cameraComponents.Feedback!(key, "matView")(matView);
    }

    {
        enum key = cameraComponentID;
        DryECS.systems.camerasystem.UpdateProjectionMatrices(
            cameraComponents.Get!(key, float, "fov"),
            cameraComponents.Set!(key, mat4, "matProj"));
    }

    {
        enum key = cameraComponentID;
        DryECS.systems.camerasystem.CombineMatrices(
            cameraComponents.Get!(key, mat4, "matView"),
            cameraComponents.Get!(key, mat4, "matProj"),
            cameraComponents.Set!(key, mat4, "matViewProj"));
    }
}