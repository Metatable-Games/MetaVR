--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local Players = game:GetService("Players")

local Packages: Folder = script.Parent.Parent.Parent:WaitForChild("Packages")

local RateLimiter = require(Packages:WaitForChild("RateLimiter"))
local Remotes = require(Packages:WaitForChild("KnightRemotes"))

local IKAvatarGesturesTypes = require(script.Parent:WaitForChild("Types"))

local IKAvatarGestures = {}
IKAvatarGestures.__index = IKAvatarGestures

export type ServerIKAvatarGestures = {
	IKRateLimit: RateLimiter.RateLimiter?,

	Init: () -> nil,
	ValidateReplicationPacket: (Packet: IKAvatarGesturesTypes.IKAvatarGestureReplicationPacket) -> nil,
	BindEvents: () -> nil,
} & typeof(setmetatable({}, IKAvatarGestures))

function IKAvatarGestures:Init()
	self.IKRateLimit = RateLimiter.new(self.Configuration.Movement.IKReplicationRateLimit)
	self:BindEvents()
end

function IKAvatarGestures:ValidateReplicationPacket(
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

function IKAvatarGestures:BindEvents()
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

return IKAvatarGestures;