--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local VRCamera = {}
VRCamera.__index = VRCamera

local MetaVRType = require(script.Parent.Parent)

export type VRCamera = {} & typeof(setmetatable({}, VRCamera))

function VRCamera.new(MetaVR: MetaVRType.MetaVR): VRCamera
    local self = setmetatable({
        MetaVR = MetaVR,
    }, VRCamera)

    return self;
end

function VRCamera:Init()
end

return VRCamera