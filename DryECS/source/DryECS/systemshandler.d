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

import std.array;
import std.traits;
import std.conv;
import std.algorithm;
import std.uni;


string GetSOANameFromComponent(string component)
{
    string SOAName = component[0..1].toLower() ~ component[1..component.length] ~ "s";
    return SOAName;
}

int _AddId(ref string[] knownComponents, ref int[] componentIds, string component)
{
    knownComponents ~= component;
    int id = 1 << componentIds.length;
    componentIds ~= id;
    return id;
}

int _GetId(ref string[] knownComponents, ref int[] componentIds, string component)
{
    for(int i = 0; i < knownComponents.length; i++)
    {
        if (component == knownComponents[i])
        {
            return componentIds[i];
        }
    }
    return -1;
}

int _GetKey(alias System)(ref string[] knownComponents, ref int[] componentIds)
{
    int key = 0;
    alias outputs = getUDAs!(System, Out);
    alias inputs = getUDAs!(System, In);

    foreach (output; outputs) // Find all outputs used components
    {
        string component;
        string name;
        SplitFQN(output.variable, component, name);

        string moduleName;
        string componentName;
        SplitFQN(component, moduleName, componentName);

        int id = _GetId(knownComponents, componentIds, componentName);
        if (id == -1)
        {
            id = _AddId(knownComponents, componentIds, componentName);
        }
        if (!(key & id))
        {
            key += id;
        }
    }

    foreach (input; inputs) // Find all inputs used components
    {
        string component;
        string name;
        SplitFQN(input.variable, component, name);

        string moduleName;
        string componentName;
        SplitFQN(component, moduleName, componentName);

        int id = _GetId(knownComponents, componentIds, componentName);
        if (id == -1)
        {
            id = _AddId(knownComponents, componentIds, componentName);
        }
        if (!(key & id))
        {
            key += id;
        }
    }

    return key;
}

string _GenSystemUpdate(alias System)(ref string[] knownComponents, ref int[] componentIds)
{
    int key = _GetKey!(System)(knownComponents, componentIds);
    auto func = appender!string;

    string[] variables;
    string[] parameters;
    

    func.put("// " ~ fullyQualifiedName!(System) ~ "\n");

    alias outputs = getUDAs!(System, Out);
    alias inputs = getUDAs!(System, In);

    foreach (output; outputs) // Find all outputs and map them to their parameters
    {
        string component;
        string name;
        SplitFQN(output.variable, component, name);

        string moduleName;
        string componentName;
        SplitFQN(component, moduleName, componentName);

        string SOAName = GetSOANameFromComponent(componentName);

        func.put("auto out_" ~ name ~ " = " ~ SOAName ~ ".Write!(" ~ to!string(key) ~ ", " ~ typeof(mixin(output.variable)).stringof ~ ", \"" ~ name ~ "\");\n"); // Declare them
        variables ~= "out_" ~ name;
        parameters ~= output.parameter;
        //func.put("auto out_\n");
    }

    foreach (input; inputs) // Find all inputs and map them to their parameters
    {
        string component;
        string name;
        SplitFQN(input.variable, component, name);

        string moduleName;
        string componentName;
        SplitFQN(component, moduleName, componentName);

        string SOAName = GetSOANameFromComponent(componentName);
        
        variables ~= SOAName ~ ".Read!(" ~ to!string(key) ~ ", " ~ typeof(mixin(input.variable)).stringof ~ ", \"" ~ name ~ "\")";
        parameters ~= input.parameter;
    }

    string fqn = fullyQualifiedName!System;

    func.put(fqn ~ "(");

    bool first = true;
    foreach (parameter; ParameterIdentifierTuple!System) // Find the parameter name and match them with the registered ins/outs
    {
        bool found = false;
        for(int i = 0; i < parameters.length; i++)
        {
            if (parameter == parameters[i])
            {
                if (!first)
                    func.put(",\n");
                func.put(variables[i]);
                found = true;
                break;
            }
        }
        
        assert(found, "Error: ECS System " ~ fqn ~ " (" ~ to!string(key) ~ ") has an unbound parameter '" ~ parameter ~ "', this is not allowed");
        first = false;
    }

    func.put(");\n");

    foreach (output; outputs) // Feedback outputs into components
    {
        string component;
        string name;
        SplitFQN(output.variable, component, name);

        string moduleName;
        string componentName;
        SplitFQN(component, moduleName, componentName);

        string SOAName = GetSOANameFromComponent(componentName);

        func.put(SOAName ~ ".Feedback!(" ~ to!string(key) ~ ", \"" ~ name ~ "\")(" ~ "out_" ~ name ~ ");\n"); // Declare them
    }

    func.put("\n");

    return func.data;
}

string _GenModuleUpdate(alias Module)(ref string[] knownComponents, ref int[] componentIds)
{   
    auto func = appender!string;

    string[] doneSystems;

    alias systems = getSymbolsByUDA!(Module, In);


    foreach(system; systems)
    {
        if (doneSystems.canFind(fullyQualifiedName!(system)))
            continue;
        
        func.put(_GenSystemUpdate!(system)(knownComponents, componentIds));

        doneSystems ~= fullyQualifiedName!(system);
    }
    return func.data;
}



string GenUpdate()
{
    string[] knownComponents;
    int[] componentIds;

    auto func = appender!string;
    func.put("{\n");

    int id = 0;
    func.put(_GenModuleUpdate!(DryECS.systems.transform)(knownComponents, componentIds));
    func.put(_GenModuleUpdate!(DryECS.systems.camera)(knownComponents, componentIds));
    func.put(_GenModuleUpdate!(DryECS.systems.lightcull)(knownComponents, componentIds));

    func.put("\n}");

    // Get the array out:
    return func.data;
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
            cameraComponents.Read!(key1, mat4, "matViewProj"));
    }
}