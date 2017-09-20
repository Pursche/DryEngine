module DryECS.utils;

import gl3n.linalg;
import std.traits;

struct Component{}
struct System{}

struct In(alias Variable)
{
    enum variable = fullyQualifiedName!(Variable);
    string parameter;
}

struct Out(alias Variable)
{
    enum variable = fullyQualifiedName!(Variable);
    string parameter;
}

struct InAll(alias Variable)
{
    alias variable = Variable;
    string parameter;
}

struct OutAll(alias Variable)
{
    alias variable = Variable;
    string parameter;
}

template SOA(Struct) 
{
    struct SOA  
    {
        enum MEMBERNAME(size_t N) = __traits(identifier, Struct.tupleof[N]);

        static __gentypes() 
        {
            string ret;
            foreach (I, TYPE; typeof(Struct.tupleof))
                ret ~= "typeof(Struct.tupleof["~I.stringof~"])[] "~MEMBERNAME!I~";";
            return ret;
        }
        mixin(__gentypes());

        public this(size_t capacity)
        {
            foreach (I, TYPE; typeof(Struct.tupleof))
                mixin(MEMBERNAME!I ~ " = new "~TYPE.stringof~"[capacity];");
        }

        public void Copy(size_t src, size_t dst)
        {
            foreach (I, TYPE; typeof(Struct.tupleof))
            {
                mixin(MEMBERNAME!I ~ "[dst] = " ~ MEMBERNAME!I ~ "[src];");
            }
        }
    }
}

import std.string;
void SplitFQN(string fqn, out string namespace, out string name)
{
    int index = cast(int)fqn.lastIndexOf('.');
    namespace = fqn[0 .. index];
    name = fqn[index+1 .. fqn.length];
}