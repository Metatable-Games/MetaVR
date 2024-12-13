--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local RunService = game:GetService("RunService")
local MetaVRType = require(script.Parent.Parent)

local IKAG_Server = RunService:IsServer() and require(script:WaitForChild("Server")) or nil
local IKAG_Client = RunService:IsClient() and require(script:WaitForChild("Client")) or nil

local IKAvatarGestures = {
	Server = {},
	Client = {},
}

function IKAvatarGestures.Client.new(MetaVR: MetaVRType.MetaVR): IKAG_Client.ClientIKAvatarGestures
	local self = setmetatable({
		MetaVR = MetaVR,
	}, IKAG_Client)

	return self
end

function IKAvatarGestures.Server.new(MetaVR: MetaVRType.MetaVR): IKAG_Server.ServerIKAvatarGestures
	local self = setmetatable({
		MetaVR = MetaVR,
	}, IKAG_Server)

	return self
end

return RunService:IsServer() and IKAvatarGestures.Server or IKAvatarGestures.Client