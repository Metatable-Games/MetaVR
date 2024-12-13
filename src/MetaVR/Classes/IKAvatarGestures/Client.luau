--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Packages: Folder = script.Parent.Parent.Parent:WaitForChild("Packages")

local Remotes = require(Packages:WaitForChild("KnightRemotes"))

local IKAvatarGesturesTypes = require(script.Parent:WaitForChild("Types"))

local IKAvatarGestures = {}
IKAvatarGestures.__index = IKAvatarGestures

export type ClientIKAvatarGestures = {
	Init: () -> nil,
} & typeof(setmetatable({}, IKAvatarGestures.Client))

function IKAvatarGestures:Init()
	task.spawn(function()
		for i = 1, 600 do
			local Worked = pcall(function()
				if not self.MetaVR.Configuration.RobloxVRControllerPreviewEnabled then
					StarterGui:SetCore("VREnableControllerModels", false)
				end
                
				if not self.MetaVR.Configuration.RobloxVRLaserEnabled then
					-- tbd
				end
			end)

			if Worked then
				break
			end
            
			task.wait(0.1)
		end
	end)

	Remotes:Connect(
		"IKAvatarGestures:Replicate",
		function(Packet: IKAvatarGesturesTypes.IKAvatarGestureReplicationPacket)
			local s, e = pcall(self.ValidateReplicationPacket, self, Packet)

			if not s then
				warn("IKAvatarGestures: ", e)
				return
			end

			local Character: Model? = Packet.Origin.Character

			if not Character then
				return
			end
		end
	)

	Remotes:Fire("IKAvatarGestures:ReadyForReplication")
end

return IKAvatarGestures;