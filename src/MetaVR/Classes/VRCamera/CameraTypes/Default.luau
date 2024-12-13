--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local VRCameraType = {}
VRCameraType.__index = VRCameraType

local VRCameraTypes = require(script.Parent.Parent:WaitForChild("Types"))

export type VRCameraType = VRCameraTypes.BaseVRCameraType & {
    new: () -> VRCameraType,
} & typeof(setmetatable({}, VRCameraType))

function VRCameraType.new(VRCamera): VRCameraType
    return setmetatable({
        VRCamera = VRCamera,
        Enabled = false,
    }, VRCamera)
end

function VRCameraType:Enable()
    self.VRCamera.CurrentCameraType = "Default"
    self.Enabled = true
end

function VRCameraType:Disable()
    self.Enabled = false
end

function VRCameraType:Update()
    
end

return VRCameraType