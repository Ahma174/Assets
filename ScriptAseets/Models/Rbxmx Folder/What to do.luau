-- Load it via game:GetObjects() and getcustomasset() like this
local m = getcustomasset("Chaos Legend Hydra.rbxmx") -- Put the rbxmx file in your workspace folder or it won't work and throws a error
local o = game:GetObjects(m) -- game:GetObjects'it so it loads the model
local model = o[1]
model.Parent = workspace -- puts it in workspace
