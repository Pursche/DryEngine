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
import DryECS.components.transform;
import DryECS.components.camera;
import DryECS.components.pointlight;

import DryECS.systems.transform;
import DryECS.systems.camera;
import DryECS.systems.lightcull;

enum transformComponentID  = (1 << 0);
enum cameraComponentID = (1 << 1);
enum pointLightComponentID = (1 << 2);

// Do this for each component found, 32 is how many we can max have
// 1 is how many unique systems (in terms of key) use this component
ComponentStore!(TransformComponent, transformComponentID) transformComponents;
ComponentStore!(CameraComponent, cameraComponentID) cameraComponents;
ComponentStore!(PointLightComponent, pointLightComponentID) pointLightComponents;

void Init() // Will be auto generated
{
    transformComponents = new ComponentStore!(TransformComponent, transformComponentID)(64);
    cameraComponents = new ComponentStore!(CameraComponent, cameraComponentID)(32);
    pointLightComponents = new ComponentStore!(PointLightComponent, pointLightComponentID)(1024);
}

void Start() // This will be auto generated
{
}

void Update(float deltaTime) // Will be auto generated
{
    transformComponents.Verify();
    cameraComponents.Verify();
    pointLightComponents.Verify();

    {
        enum key = transformComponentID;
        auto out_matWorld = transformComponents.Write!(key, mat4, "matWorld"); // zero overhead
        DryECS.systems.transform.Update(
            transformComponents.Read!(key, vec3, "position"), // zero overhead
            transformComponents.Read!(key, quat, "rotation"), // zero overhead
            transformComponents.Read!(key, vec3, "scale"), // zero overhead
            out_matWorld);
        transformComponents.Feedback!(key, "matWorld")(out_matWorld); // zero overhead
    }

    {
        enum key = transformComponentID | cameraComponentID;
        auto out_matView = cameraComponents.Write!(key, mat4, "matView");
        DryECS.systems.camera.UpdateViewMatrices(
            transformComponents.Read!(key, mat4, "matWorld"),
            out_matView);
        cameraComponents.Feedback!(key, "matView")(out_matView);
    }

    {
        enum key = cameraComponentID;
        auto out_matProj = cameraComponents.Write!(key, mat4, "matProj"); // zero overhead
        DryECS.systems.camera.UpdateProjectionMatrices(
            cameraComponents.Read!(key, float, "fov"), // zero overhead
            out_matProj);
        cameraComponents.Feedback!(key, "matProj")(out_matProj); // zero overhead
    }

    {
        enum key = cameraComponentID;
        auto out_matViewProj = cameraComponents.Write!(key, mat4, "matViewProj"); // zero overhead
        DryECS.systems.camera.CombineMatrices(
            cameraComponents.Read!(key, mat4, "matView"), // zero overhead
            cameraComponents.Read!(key, mat4, "matProj"), // zero overhead
            out_matViewProj);
        cameraComponents.Feedback!(key, "matViewProj")(out_matViewProj); // zero overhead
    }

    {
        enum key0 = transformComponentID | pointLightComponentID;
        enum key1 = cameraComponentID;
        DryECS.systems.lightcull.Cull(
            transformComponents.Read!(key0, vec3, "position"),
            pointLightComponents.Read!(key0, float, "radius"),
            cameraComponents.Read!(key1, mat4, "matViewProj"));
    }
}