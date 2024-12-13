--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local Packages: Folder = script.Parent.Parent:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local VRInputService_Singleton = nil

local VRInputService = {}
VRInputService.__index = VRInputService

export type VRInputService = {
	ManualNormalHeadLevel: number?,
	HighestHeadHeight: number?,
	RecenterOffset: CFrame,

	ThumbstickValues: {
		[Enum.KeyCode]: Vector3,
	},

	Recentered: BindableEvent,
	EyeLevelSet: BindableEvent,

	new: () -> VRInputService,
	GetInstance: () -> VRInputService,
	Init: () -> (),
	Destroy: () -> (),
	SetEyeLevel: () -> (),
	Recenter: () -> (),
	GetThumbstickPosition: (Thumbsick: Enum.KeyCode) -> Vector3,
	GetVRInputs: () -> { [Enum.UserCFrame]: CFrame },
} & typeof(setmetatable({}, VRInputService))

function VRInputService.new(): VRInputService
	local self = setmetatable({}, VRInputService)

	self.Maid = Maid.new()

	self.Recentered = Instance.new("BindableEvent")
	self.EyeLevelSet = Instance.new("BindableEvent")

	self.Maid:GiveTask(self.Recentered)
	self.Maid:GiveTask(self.EyeLevelSet)

	self.RecenterOffset = CFrame.identity
	self.ThumbstickValues = {
		[Enum.KeyCode.Thumbstick1] = Vector3.zero,
		[Enum.KeyCode.Thumbstick2] = Vector3.zero,
	}

	self:Init()

	return self
end

function VRInputService.GetInstance(): VRInputService
	if not VRInputService_Singleton then
		VRInputService_Singleton = VRInputService.new()
	end

	return VRInputService_Singleton
end

function VRInputService:Init(): ()
	self.Maid:GiveTask(UserInputService.InputEnded:Connect(function(Input: InputObject, GPE: boolean)
		if GPE then
			return
		end

		if self.ThumbstickValues[Input.KeyCode] then
			self.ThumbstickValues[Input.KeyCode] = Vector3.zero
		end
	end))

	self.Maid:GiveTask(UserInputService.InputChanged:Connect(function(Input: InputObject, GPE: boolean)
		if GPE then
			return
		end

		if self.ThumbstickValues[Input.KeyCode] then
			self.ThumbstickValues[Input.KeyCode] = Input.Position
		end
	end))
end

function VRInputService:GetVRInputs(): { [Enum.UserCFrame]: CFrame }
	local VRInputs = {
		[Enum.UserCFrame.Head] = VRService:GetUserCFrame(Enum.UserCFrame.Head),
	} :: { [Enum.UserCFrame]: CFrame }

	if VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand) then
		VRInputs[Enum.UserCFrame.LeftHand] = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
	else
		VRInputs[Enum.UserCFrame.LeftHand] = VRInputs[Enum.UserCFrame.Head] * CFrame.new(-1, -2.5, 0.5)
	end

	if VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) then
		VRInputs[Enum.UserCFrame.RightHand] = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
	else
		VRInputs[Enum.UserCFrame.RightHand] = VRInputs[Enum.UserCFrame.Head] * CFrame.new(1, -2.5, 0.5)
	end

	local HeightOffset: number = 0

	if not self.ManualNormalHeadLevel then
		local CurrentVRHeadHeight = (VRInputs[Enum.UserCFrame.Head] * CFrame.new(0, 0, 0.5)).Y

		if not self.HighestHeadHeight or CurrentVRHeadHeight > self.HighestHeadHeight then
			self.HighestHeadHeight = CurrentVRHeadHeight
		end

		HeightOffset = -self.HighestHeadHeight :: number
	else
		HeightOffset = -self.ManualNormalHeadLevel
	end

	for _, InputEnum in { Enum.UserCFrame.Head, Enum.UserCFrame.LeftHand, Enum.UserCFrame.RightHand } do
		VRInputs[InputEnum] = CFrame.new(0, HeightOffset, 0) * self.RecenterOffset * VRInputs[InputEnum]
	end

	return VRInputs
end

function VRInputService:GetThumbstickPosition(Thumbsick: Enum.KeyCode): Vector3
	return self.ThumbstickValues[Thumbsick] or Vector3.zero
end

function VRInputService:SetEyeLevel(): ()
	self.ManualNormalHeadLevel = VRService:GetUserCFrame(Enum.UserCFrame.Head).Y
	self.EyeLevelSet:Fire()
end

function VRInputService:Recenter(): ()
	local HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)

	self.RecenterOffset = CFrame.Angles(0, -math.atan2(-HeadCFrame.LookVector.X, -HeadCFrame.LookVector.Z), 0)
		* CFrame.new(-HeadCFrame.X, 0, -HeadCFrame.Z)
	self.Recentered:Fire()
end

function VRInputService:Destroy(): ()
	if VRInputService_Singleton == self then
		VRInputService_Singleton = nil
	end

	self.Maid:Destroy()
	self = nil
end

return VRInputService
