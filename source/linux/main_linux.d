import DryECS.systemshandler;

int main(string[] args)
{
    LoadECS();

    for (size_t i = 0; i < 8; ++i)
	{
        transformComponents.Add(transformComponentID | cameraComponentID);
        cameraComponents.Add(transformComponentID | cameraComponentID);
	}

    for (size_t i = 0; i < 8; ++i)
	{
        transformComponents.Add(transformComponentID);
	}

    for (size_t i = 0; i < 8; ++i)
	{
        transformComponents.Add(transformComponentID | pointLightComponentID);
        pointLightComponents.Add(transformComponentID | pointLightComponentID);
	}

    transformComponents.Print();
    cameraComponents.Print();
    pointLightComponents.Print();

    Update(0.0f);

    UnloadECS();
    return 0;
}