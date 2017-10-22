module ecspass;

import std.file;
import std.stdio;
import std.string;
import std.array;
import std.path;

string PathUp(string path)
{
    return path[0 .. lastIndexOf(path, dirSeparator)];
}

string GetModule(string path)
{
    size_t start = indexOf(path, buildPath("DryECS", "systems"));
    if (start == -1)
        start = indexOf(path, buildPath("DryECS", "components"));
    size_t end = lastIndexOf(path, ".d");

    return path[start .. end].replace(dirSeparator, ".");
}

string GetImport(string mod)
{
    return "public import " ~ mod ~ ";"; 
}

void Run()
{
    writeln("Precompiler: Pregenerating ECS code");
    string exePath = thisExePath();
    string[] systems;
    string[] components;
    string[] imports;

    string systemsPath = exePath.PathUp().PathUp() ~ dirSeparator ~ buildPath("DryECS", "source", "DryECS", "systems");
    foreach (string name; dirEntries(systemsPath, SpanMode.depth))
    {
        imports ~= name.GetModule().GetImport();
        systems ~= name.GetModule();
    }
    string componentsPath = exePath.PathUp().PathUp() ~ dirSeparator ~ buildPath("DryECS", "source", "DryECS", "components");
    foreach (string name; dirEntries(componentsPath, SpanMode.depth))
    {
        imports ~= name.GetModule().GetImport();
        components ~= name.GetModule();
    }
    
    string includeDir = exePath.PathUp().PathUp() ~ dirSeparator ~ buildPath("DryECS", "source", "DryECS", "__generated__");
    if (!exists(includeDir))
    {
        mkdir(includeDir);
    }
    string includePath = buildPath(includeDir, "includes.d");
    File includeFile = File(includePath, "w");
    includeFile.writeln("module DryECS.__generated__.includes;\n");
    foreach(string imp; imports)
    {
        includeFile.writeln(imp);
    }
    
    // GenUpdate()
    includeFile.writeln("");
    includeFile.writeln("string GenUpdate()");
    includeFile.writeln("{");
    includeFile.writeln("   string[] knownComponents;");
    includeFile.writeln("   int[] componentIds;");
    includeFile.writeln("   auto func = appender!string;");
    includeFile.writeln("   func.put(\"{\\n\");");
    
    foreach(string system; systems)
    {
        includeFile.writeln("   func.put(_GenModuleUpdate!(" ~ system ~ ")(knownComponents, componentIds));");
    }

    includeFile.writeln("   func.put(\"\\n}\");");
    includeFile.writeln("   return func.data;");
    includeFile.writeln("}");

    // GenComponentStores()
    includeFile.writeln("");
    includeFile.writeln("string GenComponentStores()");
    includeFile.writeln("{");
    includeFile.writeln("   string[] knownComponents;");
    includeFile.writeln("   int[] componentIds;");
    includeFile.writeln("   auto func = appender!string;");
    
    foreach(string component; components)
    {
        includeFile.writeln("   func.put(_GenModuleComponentStore!(" ~ component ~ ")(knownComponents, componentIds));");
    }

    includeFile.writeln("   return func.data;");
    includeFile.writeln("}");

    /*string GenInit()
{
    string[] knownComponents;
    int[] componentIds;
    auto func = appender!string;
    func.put("try\n");
    func.put("{\n");
   
    func.put(_GenModuleInit!(DryECS.components.camera)(knownComponents, componentIds));
    func.put(_GenModuleInit!(DryECS.components.mesh)(knownComponents, componentIds));
    func.put(_GenModuleInit!(DryECS.components.meshcollider)(knownComponents, componentIds));
    func.put(_GenModuleInit!(DryECS.components.pointlight)(knownComponents, componentIds));
    func.put(_GenModuleInit!(DryECS.components.transform)(knownComponents, componentIds));
    func.put("}\n");
    func.put("catch (Throwable e)\n");
    func.put("{\n");
    func.put("import core.sys.windows.windows;\n");
    func.put("MessageBoxA(null, e.msg.toStringz(), null, MB_ICONERROR);\n");
    func.put("}");
    return func.data;
}*/

    // GenInit()
    includeFile.writeln("");
    includeFile.writeln("string GenInit()");
    includeFile.writeln("{");
    includeFile.writeln("   string[] knownComponents;");
    includeFile.writeln("   int[] componentIds;");
    includeFile.writeln("   auto func = appender!string;");
    includeFile.writeln("   func.put(\"try\\n\");");
    includeFile.writeln("   func.put(\"{\\n\");");
    
    foreach(string component; components)
    {
        includeFile.writeln("   func.put(_GenModuleInit!(" ~ component ~ ")(knownComponents, componentIds));");
    }
    includeFile.writeln("   func.put(\"}\\n\");");
    includeFile.writeln("   func.put(\"catch (Throwable e)\\n\");");
    includeFile.writeln("   func.put(\"{\\n\");");
    includeFile.writeln("   func.put(\"import core.sys.windows.windows;\\n\");");
    includeFile.writeln("   func.put(\"MessageBoxA(null, e.msg.toStringz(), null, MB_ICONERROR);\\n\");");
    includeFile.writeln("   func.put(\"}\\n\");");

    includeFile.writeln("   return func.data;");
    includeFile.writeln("}");

    string[] templateLines;
    string templatePath = exePath.PathUp().PathUp() ~ dirSeparator ~ buildPath("DryECS", "source", "DryECS", "includes.dtemplate");
    File templateFile = File(templatePath, "r");
    auto lines = templateFile.byLine();

    foreach(line; lines)
    {
         includeFile.writeln(line);
    }
}
