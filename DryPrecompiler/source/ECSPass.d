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
    string exePath = thisExePath();
    string[] imports;

    string systemsPath = exePath.PathUp().PathUp() ~ dirSeparator ~ buildPath("DryECS", "source", "DryECS", "systems");
    foreach (string name; dirEntries(systemsPath, SpanMode.depth))
    {
        imports ~= name.GetModule().GetImport();
    }
    string componentsPath = exePath.PathUp().PathUp() ~ dirSeparator ~ buildPath("DryECS", "source", "DryECS", "components");
    foreach (string name; dirEntries(componentsPath, SpanMode.depth))
    {
        imports ~= name.GetModule().GetImport();
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
}