--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")

local Packages: Folder = script.Parent.Parent:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local LocalPlayer = Players.LocalPlayer

local VRCamera = {}
VRCamera.__index = VRCamera

local MetaVRType = require(script.Parent.Parent)
local VRCameraType = require(script:WaitForChild("Types"))

export type VRCamera = {
	MetaVR: MetaVRType.MetaVR,

	Camera: Camera,
	CurrentCameraType: string,
	Cameras: {
		[string]: VRCameraType.BaseVRCameraType,
	},

	new: (MetaVR: MetaVRType.MetaVR) -> VRCamera,
	Init: () -> (),
	Destroy: () -> (),
	Update: () -> (),
} & typeof(setmetatable({}, VRCamera))

function VRCamera.new(MetaVR: MetaVRType.MetaVR): VRCamera
	local self = setmetatable({
		MetaVR = MetaVR,
	}, VRCamera)

	self.Maid = Maid.new()
	self.Camera = workspace.CurrentCamera

	self.Cameras = {}
	self.CurrentCameraType = "Disabled"

	self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
	for i, v in pairs(script:WaitForChild("CameraTypes"):GetChildren()) do
		if v:IsA("ModuleScript") then
			self.Cameras[v.Name] = require(v).new(self)
		end
	end

	if self.MetaVR.Configuration.Camera.MetaVRCameraEnabled then
		assert(
			self.Cameras[self.MetaVR.Configuration.Camera.DefaultCameraOption] ~= nil,
			"MetaVR: Default camera option not found."
		)
		self.Cameras[self.MetaVR.Configuration.Camera.DefaultCameraOption]:Enable()
	else
		self.Cameras["Disabled"]:Enable()
	end

	return self
end

function VRCamera:Update()
	if not self.MetaVR.Configuration.Camera.DisableHeadLocked then
		workspace.CurrentCamera.HeadLocked = false
	end

	if self.MetaVR.Configuration.Camera.DisableFadeOutViewOnCollision then
		VRService.FadeOutViewOnCollision = false
	end

	if self.CurrentCameraType == "Disabled" then
		return
	end

	if
		not self.Character
		or (self.Character and not self.Character:IsDescendantOf(workspace))
		or (self.Character and not self.Character:FindFirstChildWhichIsA("Humanoid"))
		or (self.Character and self.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0)
	then
		return
	end

	local HeadsetCFrameWorld: CFrame = CFrame.new()
	local TargetCFrame: CFrame = CFrame.new()

	if self.Camera.HeadLocked then
		local HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		TargetCFrame = HeadsetCFrameWorld
			* (CFrame.new(HeadCFrame.Position * (self.Camera.HeadScale - 1)) * HeadCFrame):Inverse()
		self.Camera.VRTiltAndRollEnabled = true
	end

	self.Camera.CameraType = Enum.CameraType.Scriptable
	self.Camera.CFrame = TargetCFrame
	self.Camera.Focus = TargetCFrame

	self.Cameras[self.CurrentCameraType]:Update(HeadsetCFrameWorld, TargetCFrame)
end

function VRCamera:Init()
	self.Maid:GiveTask(RunService.RenderStepped:Connect(function()
		return self:Update()
	end))
end

function VRCamera:Destroy()
	self.Maid:Destroy()
	self = nil
end

return VRCamera
