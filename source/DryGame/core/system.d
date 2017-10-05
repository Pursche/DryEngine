module DryGame.core.system;

import DryGame.ecs.ecswrapper;

class System
{
    public this(string[] args)
    {
        DryGame.ecs.ecswrapper.LoadECS();
    }

    ~this()
    {
        DryGame.ecs.ecswrapper.UnloadECS();
    }

    public void Update()
    {
        DryGame.ecs.ecswrapper.Update(0.5f);
    }
}