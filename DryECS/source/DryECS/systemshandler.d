module DryECS.systemshandler;
import DryECS.componentstore;
import std.stdio;
import std.string;

// Autogeneration begins

// These should be here no matter what components we have etc
import DryECS.utils;
import gl3n.linalg;

// This file has all our generated includes
import DryECS.__generated__.includes;

enum transformComponentID  = (1 << 0);
enum cameraComponentID = (1 << 1);
enum pointLightComponentID = (1 << 2);
enum meshComponentID = (1 << 3);

ComponentStore!(TransformComponent, transformComponentID) transformComponents;
ComponentStore!(CameraComponent, cameraComponentID) cameraComponents;
ComponentStore!(PointLightComponent, pointLightComponentID) pointLightComponents;
ComponentStore!(MeshComponent, meshComponentID) meshComponents;

export void Init() // Will be auto generated
{
    try
    {
        transformComponents = new typeof(transformComponents)(64);
        cameraComponents = new typeof(cameraComponents)(32);
        pointLightComponents = new typeof(pointLightComponents)(1024);
        meshComponents = new typeof(meshComponents)(1024);
    }
    catch (Throwable e) 
    {
        import core.sys.windows.windows;
        MessageBoxA(null, e.msg.toStringz(), null, MB_ICONERROR);
    }
    
    debug(1)
    {
    	File generatedCode = File("generatedECS.d", "w");
	generatedCode.writeln(GenUpdate());
    }
}

export EntityID CreateEntity(EntityType type)
{
    EntityID id = 0;
    _RegisterEntity(type);
    return 0;//todo
}

// todo: auto-generate
void _RegisterEntity(EntityType type)
{
    transformComponents.Add(type);
    cameraComponents.Add(type);
    pointLightComponents.Add(type);
}

void Update(float deltaTime) // Will be auto generated
{
    pragma(msg, GenUpdate());
    mixin(GenUpdate());

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
            cameraComponents.Read!(key1, mat4, "matViewProj"));// zero overhead
    }
}