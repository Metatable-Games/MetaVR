--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Packages: Folder = script.Parent.Parent:WaitForChild("Packages")

local RateLimiter = require(Packages:WaitForChild("RateLimiter"))
local Remotes = require(Packages:WaitForChild("KnightRemotes"))

local MetaVRType = require(script.Parent.Parent)
local IKAvatarGesturesTypes = require(script:WaitForChild("Types"))

local IKAvatarGestures = {
	Server = {},
	Client = {},
}

IKAvatarGestures.Server.__index = IKAvatarGestures.Server
IKAvatarGestures.Client.__index = IKAvatarGestures.Client

export type ServerIKAvatarGestures = {
	IKRateLimit: RateLimiter.RateLimiter?,

	Init: () -> nil,
	ValidateReplicationPacket: (Packet: IKAvatarGesturesTypes.IKAvatarGestureReplicationPacket) -> nil,
	BindEvents: () -> nil,
} & typeof(setmetatable({}, IKAvatarGestures.Server))

export type ClientIKAvatarGestures = {
	Init: () -> nil,
} & typeof(setmetatable({}, IKAvatarGestures.Client))

-- ///////////////////////////////////// Server ///////////////////////////////////// --

function IKAvatarGestures.Client.new(MetaVR: MetaVRType.MetaVR): ServerIKAvatarGestures
	local self = setmetatable({
		MetaVR = MetaVR,
	}, IKAvatarGestures.Server)

	return self
end

function IKAvatarGestures.Server:Init()
	self.IKRateLimit = RateLimiter.new(self.Configuration.Movement.IKReplicationRateLimit)
	self:BindEvents()
end

function IKAvatarGestures.Server:ValidateReplicationPacket(
	Packet: IKAvatarGesturesTypes.IKAvatarGestureReplicationPacket
)
	assert(
		Packet.Origin and typeof(Packet.Origin) == "Instance" and Packet.Origin:IsA("Player"),
		"IKAvatarGestures: Origin is missing or not a Player."
	)
	assert(
		Packet.HeadCFrame and typeof(Packet.HeadCFrame) == "CFrame",
		"IKAvatarGestures: HeadCFrame is missing or not a CFrame."
	)
	assert(
		Packet.LeftHandCFrame and typeof(Packet.LeftHandCFrame) == "CFrame",
		"IKAvatarGestures: LeftHandCFrame is missing or not a CFrame."
	)
	assert(
		Packet.RightHandCFrame and typeof(Packet.RightHandCFrame) == "CFrame",
		"IKAvatarGestures: RightHandCFrame is missing or not a CFrame."
	)
	assert(
		Packet.UpdateTime and typeof(Packet.UpdateTime) == "number",
		"IKAvatarGestures: UpdateTime is missing or not a number."
	)
end

function IKAvatarGestures.Server:BindEvents()
	Remotes:Register("IKAvatarGestures:ReadyForReplication", "UnreliableRemoteEvent", function(Player: Player)
		Player:AddTag("ReadyForIKAvatarGestureReplication")
	end)

	Remotes:Register(
		"IKAvatarGestures:Replicate",
		"UnreliableRemoteEvent",
		function(Player: Player, Packet: IKAvatarGesturesTypes.IKAvatarGestureReplicationPacket)
			if not self.Configuration.Movement.IKAvatarGesturesEnabled then
				return
			end

			if self.IKRateLimit:RateLimitReached(Player) then
				return
			end

			Packet.Origin = Player

			local s, e = pcall(self.ValidateReplicationPacket, self, Packet)

			if not s then
				warn("IKAvatarGestures: ", e)
				return
			end

			for _, OtherPlayer: Player in pairs(Players:GetPlayers()) do
				if OtherPlayer ~= Player and OtherPlayer:HasTag("ReadyForIKAvatarGestureReplication") then
					Remotes:Fire("IKAvatarGestures:Replicate", OtherPlayer, Packet)
				end
			end
		end
	)
end

-- ///////////////////////////////////// Client ///////////////////////////////////// --
function IKAvatarGestures.Client.new(MetaVR: MetaVRType.MetaVR): ClientIKAvatarGestures
	local self = setmetatable({
		MetaVR = MetaVR,
	}, IKAvatarGestures.Client)

	return self
end

function IKAvatarGestures.Client:Init()
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

return RunService:IsServer() and IKAvatarGestures.Server or IKAvatarGestures.Client
