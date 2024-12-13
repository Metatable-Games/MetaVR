--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")


--- DEBUG --
local Players = game:GetService("Players")

local RateLimiter = {}
RateLimiter.__index = RateLimiter

type void = nil

export type PlayerLimitData = {
	StartTime: number,
	RequestCount: number,
}

export type RateLimiter = {
	MaxRequests: number,
	RefreshDuration: number,
	PlayerLimits: { [Player]: PlayerLimitData },
	PlayerDisconnectionSignal: RBXScriptConnection,

	new: (MaxRequests: number?, RefreshDuration: number?) -> RateLimiter,
	Destroy: () -> void,
	AddPlayer: (Player: Player) -> void,
	RemovePlayer: (Player: Player) -> void,
	RateLimitReached: (Player: Player) -> boolean,
} & typeof(setmetatable({}, RateLimiter))

function RateLimiter.new(MaxRequests: number?, RefreshDuration: number?): RateLimiter
	assert(not MaxRequests or (MaxRequests and type(MaxRequests) == "number"), "MaxRequests must be a number or nil")
	assert(
		not RefreshDuration or (RefreshDuration and type(RefreshDuration) == "number"),
		"RefreshDuration must be a number or nil"
	)

	local self = setmetatable({}, RateLimiter) :: RateLimiter

	self.MaxRequests = MaxRequests or 1
	self.RefreshDuration = RefreshDuration or 1
	self.PlayerLimits = {}

	self.PlayerDisconnectionSignal = Players.PlayerRemoving:Connect(function(Player: Player)
		self:RemovePlayer(Player)
	end)

	return self
end

function RateLimiter:Destroy(): void
	self.PlayerDisconnectionSignal:Disconnect()
	self = nil

	return
end

function RateLimiter:AddPlayer(Player: Player): void
	assert(Player ~= nil and typeof(Player) == "Instance" and Players:IsA("Player"), "Player must be a Player instance")

	if not self.PlayerLimits[Player] then
		self.PlayerLimits[Player] = {
			StartTime = tick(),
			RequestCount = 0,
		}
	end

	return
end

function RateLimiter:RemovePlayer(Player: Player): void
	assert(Player ~= nil and typeof(Player) == "Instance" and Players:IsA("Player"), "Player must be a Player instance")

	if self.PlayerLimits[Player] then
		self.PlayerLimits[Player] = nil
	end

	return
end

function RateLimiter:RateLimitReached(Player: Player): boolean
	assert(Player ~= nil and typeof(Player) == "Instance" and Players:IsA("Player"), "Player must be a Player instance")

	self:AddPlayer(Player)

	local PlayerData: PlayerLimitData = self.PlayerLimits[Player]
	local CurrentTime: number = tick()

	if CurrentTime > (PlayerData.StartTime + self.RefreshDuration) then
		PlayerData.StartTime = CurrentTime
		PlayerData.RequestCount = 0
	end

	if PlayerData.RequestCount >= self.MaxRequests then
		return true
	end

	PlayerData.RequestCount += 1
	return false
end

return RateLimiter

--- DEBUG --

--return require(Packages:FindFirstChild("MetaRateLimiter") or 81660957924555)