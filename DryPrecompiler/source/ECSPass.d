module ecspass;

import std.file;
import std.stdio;
import std.string;
import std.array;

string PathUp(string path)
{
    return path[0 .. lastIndexOf(path, '\\')];
}

string GetModule(string path)
{
    size_t start = indexOf(path, "DryECS\\systems");
    if (start == -1)
        start = indexOf(path, "DryECS\\components");
    size_t end = lastIndexOf(path, ".d");

    return path[start .. end].replace("\\", ".");
}

string GetImport(string mod)
{
    return "public import " ~ mod ~ ";"; 
}

void Run()
{
    string exePath = thisExePath();
    string[] imports;

    string systemsPath = exePath.PathUp().PathUp() ~ "\\DryECS\\source\\DryECS\\systems";
    foreach (string name; dirEntries(systemsPath, SpanMode.depth))
    {
        imports ~= name.GetModule().GetImport();
    }
    string componentsPath = exePath.PathUp().PathUp() ~ "\\DryECS\\source\\DryECS\\components";
    foreach (string name; dirEntries(componentsPath, SpanMode.depth))
    {
        imports ~= name.GetModule().GetImport();
    }

    string includePath = exePath.PathUp().PathUp() ~ "\\DryECS\\source\\DryECS\\systemincludes.d";
    File includeFile = File(includePath, "w");
    includeFile.writeln("module DryECS.systemincludes;\n");
    foreach(string imp; imports)
     {
         includeFile.writeln(imp);
     }
}