module DryECS.utils;

struct In(alias Variable)
{
    alias variable = Variable;
    string parameter;
}

struct Out(alias Variable, )
{
    alias variable = Variable;
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

template SOA(Struct, size_t LENGTH) 
{
    struct SOA  
    {
        enum MEMBERNAME(size_t N) = __traits(identifier, Struct.tupleof[N]);

        static __gentypes() 
        {
            string ret;
            foreach (I, TYPE; typeof(Struct.tupleof))
                ret ~= "align(16) typeof(Struct.tupleof["~I.stringof~"])["~LENGTH.stringof~"] "
                        ~ MEMBERNAME!I ~ ";";
            return ret;
        }
        mixin(__gentypes());
    }
}