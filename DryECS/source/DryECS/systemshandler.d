module DryECS.systemshandler;
import DryECS.componentstore;
import std.stdio;
import std.string;

// This file relies heavily on compiletime generated code. Here is a quick rundown of the flow
// We start by compiling and running the DryPrecompiler project, which will generate includes.d
// (See ECSPass.d for more info how it generates, or includes.d to see the result)
// To generate includes.d, running the precompiler will:
//      1. Scan DryECS/components and DryECS/systems for modules
//      2. Add public imports of all components and systems to the top of the file
//      3. Generate root generation functions, for example the GenUpdate function with one _GenModuleUpdate call per found component/system module
//          * This will in turn call _GenSystemUpdate for each system it finds in the module
//      4. Add the contents of includes.dtemplate to the end of includes.d, this contains functions used b the root generation functions
//      5. After pausing to compile and run DryPrecompiler before DryECS, we resume compiling DryECS
//      6. When this file gets compiled, the compiler will find the mixins, run the functions within them and evaluate their returned strings as code
//          * This will run the root generation function (e.g GenUpdate), which in turn runs the per-module generation function on each system/component module (e.g _GenModuleUpdate)
//          which in turn runs the per-system or per-component generation function on each system or component found in that module (e.g _GenSystemUpdate)
//      7. Lastly we add some runtime code to the Init function that will output a generatedECS.notd file with all our generated code for easier debugging
//      
// If you want to know what code this generates, start the game and look at generatedECS.notd next to the executable
// If you need to debug this without being able to look at generatedECS.notd, 
// you can uncomment pragma(msg, *function*) calls in this code to see the generated code in the command prompt during compilation
// As a last resort I recommend adding more pragma(msg, *function*) calls in includes.dtemplate for more detailed debugging

import DryECS.utils;
import gl3n.linalg;

// This file has all our generated includes
import DryECS.__generated__.includes;

//pragma(msg, GenComponentStores());
mixin(GenComponentStores());

export void Init()
{
    //pragma(msg, GenInit());
    mixin(GenInit());
    
    debug(1)
    {
    	File generatedCode = File("generatedECS.notd", "w");
        generatedCode.writeln("// COMPONENTSTORES");
	    generatedCode.writeln(GenComponentStores());
        generatedCode.writeln("// INIT");
	    generatedCode.writeln(GenInit());
        generatedCode.writeln("// UPDATE");
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
    //pragma(msg, GenUpdate());
    mixin(GenUpdate());

    transformComponents.Verify();
    cameraComponents.Verify();
    pointLightComponents.Verify();
}