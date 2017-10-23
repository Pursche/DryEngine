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
    transformComponents = new typeof(transformComponents)(64);
    cameraComponents = new typeof(cameraComponents)(32);
    pointLightComponents = new typeof(pointLightComponents)(1024);
    meshComponents = new typeof(meshComponents)(1024);
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

string _ParseKeys(alias System)(ref string[] knownComponents, ref int[] componentIds, out int[int] keys)
{
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

        int key = output.dependencyGroup;
        if (!(key in keys))
        {
            keys[key] = id;
        }
        else if (!(keys[key] & id))
        {
            keys[key] += id;
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

        int key = input.dependencyGroup;
        if (!(key in keys))
        {
            keys[key] = id;
        }
        else if (!(keys[key] & id))
        {
            keys[key] += id;
        }
    }

    return "";
}

string _GenSystemUpdate(alias System)(ref string[] knownComponents, ref int[] componentIds)
{
    //int key = _GetKey!(System)(knownComponents, componentIds);
    auto func = appender!string;
    int[int] keys;
    _ParseKeys!(System)(knownComponents, componentIds, keys);
    
    string[] variables;
    string[] parameters;
    
    

    func.put("// " ~ fullyQualifiedName!(System) ~ "\n");

    alias outputs = getUDAs!(System, Out);
    alias inputs = getUDAs!(System, In);

    foreach (output; outputs) // Find all outputs and map them to their parameters
    {
        int key = keys[output.dependencyGroup];
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
        int key = keys[input.dependencyGroup];
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
        
        assert(found, "Error: ECS System " ~ fqn ~ " has an unbound parameter '" ~ parameter ~ "', this is not allowed");
        first = false;
    }

    func.put(");\n");

    foreach (output; outputs) // Feedback outputs into components
    {
        int key = keys[output.dependencyGroup];
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



export void Update(float deltaTime) // Will be auto generated
{
    //pragma(msg, GenUpdate());
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