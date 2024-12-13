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

local VRCharacter = {}
VRCharacter.__index = VRCharacter

export type VRCharacter = {
	Character: Model,

	new: () -> VRCharacter,
	Init: () -> (),
} & typeof(setmetatable({}, VRCharacter))

function VRCharacter.new(): VRCharacter
	return setmetatable({}, VRCharacter)
end

function VRCharacter:BindCharacter()
	self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() :: Model
	self.Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid") :: Humanoid

	if self.Humanoid.RigType == Enum.RigType.R6 then
		self.Parts = {
			Head = self.Character:WaitForChild("Head") :: BasePart,

			Torso = self.Character:WaitForChild("Torso") :: BasePart,
			HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart") :: BasePart,

			RightArm = self.Character:WaitForChild("Right Arm") :: BasePart,
			LeftArm = self.Character:WaitForChild("Left Arm") :: BasePart,

			RightLeg = self.Character:WaitForChild("Right Leg") :: BasePart,
			LeftLeg = self.Character:WaitForChild("Left Leg") :: BasePart,
		}

		self.Motors = {
			Neck = self.Parts.Torso:WaitForChild("Neck") :: Motor6D,

			Root = self.Parts.HumanoidRootPart:WaitForChild("RootJoint") :: Motor6D,

			RightArm = self.Parts.Torso:WaitForChild("Right Shoulder") :: Motor6D,
			LeftArm = self.Parts.Torso:WaitForChild("Left Shoulder") :: Motor6D,

			RightLeg = self.Parts.Torso:WaitForChild("Right Hip") :: Motor6D,
			LeftLeg = self.Parts.Torso:WaitForChild("Left Hip") :: Motor6D,
		}

        self.Attachments = {
			Head = {
				NeckRigAttachment = self.Parts.Torso:WaitForChild("NeckAttachment") :: Attachment,
			},
			Torso = {
				LeftShoulderRigAttachment = self.Parts.Torso:WaitForChild("LeftCollarAttachment") :: Attachment,
				RightShoulderRigAttachment = self.Parts.Torso:WaitForChild("RightCollarAttachment") :: Attachment,
				WaistRigAttachment = self.Parts.Torso:WaitForChild("WaistCenterAttachment") :: Attachment,
			},
			HumanoidRootPart = {
				RootRigAttachment = self.Parts.HumanoidRootPart:WaitForChild("RootAttachment") :: Attachment,
			},
			RightArm = {
				RightShoulderRigAttachment = self.Parts["Right Arm"]:WaitForChild("RightShoulderAttachment") :: Attachment,
			},
			LeftArm = {
				LeftShoulderRigAttachment = self.Parts["Left Arm"]:WaitForChild("LeftShoulderAttachment") :: Attachment,
			},
			RightLeg = {
				RightFootAttachment = self.Parts["Right Leg"]:WaitForChild("RightFootAttachment") :: Attachment,
			},
			LeftLeg = {
				LeftFootAttachment = self.Parts["Left Leg"]:WaitForChild("LeftFootAttachment") :: Attachment,
			},
		}
    end

	if self.Humanoid.RigType == Enum.RigType.R15 then
		self.Parts = {
			Head = self.Character:WaitForChild("Head") :: BasePart,

			UpperTorso = self.Character:WaitForChild("UpperTorso") :: BasePart,
			LowerTorso = self.Character:WaitForChild("LowerTorso") :: BasePart,
			HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart") :: BasePart,

			RightUpperArm = self.Character:WaitForChild("RightUpperArm") :: BasePart,
			RightLowerArm = self.Character:WaitForChild("RightLowerArm") :: BasePart,
			RightHand = self.Character:WaitForChild("RightHand") :: BasePart,

			LeftUpperArm = self.Character:WaitForChild("LeftUpperArm") :: BasePart,
			LeftLowerArm = self.Character:WaitForChild("LeftLowerArm") :: BasePart,
			LeftHand = self.Character:WaitForChild("LeftHand") :: BasePart,

			RightUpperLeg = self.Character:WaitForChild("RightUpperLeg") :: BasePart,
			RightLowerLeg = self.Character:WaitForChild("RightLowerLeg") :: BasePart,
			RightFoot = self.Character:WaitForChild("RightFoot") :: BasePart,

			LeftUpperLeg = self.Character:WaitForChild("LeftUpperLeg") :: BasePart,
			LeftLowerLeg = self.Character:WaitForChild("LeftLowerLeg") :: BasePart,
			LeftFoot = self.Character:WaitForChild("LeftFoot") :: BasePart,
		}

		self.Motors = {
			Neck = self.Parts.Head:WaitForChild("Neck") :: Motor6D,

			Waist = self.Parts.UpperTorso:WaitForChild("Waist") :: Motor6D,
			Root = self.Parts.LowerTorso:WaitForChild("Root") :: Motor6D,

			RightShoulder = self.Parts.RightUpperArm:WaitForChild("RightShoulder") :: Motor6D,
			RightElbow = self.Parts.RightLowerArm:WaitForChild("RightElbow") :: Motor6D,
			RightWrist = self.Parts.RightHand:WaitForChild("RightWrist") :: Motor6D,

			LeftShoulder = self.Parts.LeftUpperArm:WaitForChild("LeftShoulder") :: Motor6D,
			LeftElbow = self.Parts.LeftLowerArm:WaitForChild("LeftElbow") :: Motor6D,
			LeftWrist = self.Parts.LeftHand:WaitForChild("LeftWrist") :: Motor6D,

			RightHip = self.Parts.RightUpperLeg:WaitForChild("RightHip") :: Motor6D,
			RightKnee = self.Parts.RightLowerLeg:WaitForChild("RightKnee") :: Motor6D,
			RightAnkle = self.Parts.RightFoot:WaitForChild("RightAnkle") :: Motor6D,

			LeftHip = self.Parts.LeftUpperLeg:WaitForChild("LeftHip") :: Motor6D,
			LeftKnee = self.Parts.LeftLowerLeg:WaitForChild("LeftKnee") :: Motor6D,
			LeftAnkle = self.Parts.LeftFoot:WaitForChild("LeftAnkle") :: Motor6D,
		}

		self.Attachments = {
			Head = {
				NeckRigAttachment = self.Parts.Head:WaitForChild("NeckRigAttachment") :: Attachment,
			},
			UpperTorso = {
				NeckRigAttachment = self.Parts.UpperTorso:WaitForChild("NeckRigAttachment") :: Attachment,
				LeftShoulderRigAttachment = self.Parts.UpperTorso:WaitForChild("LeftShoulderRigAttachment") :: Attachment,
				RightShoulderRigAttachment = self.Parts.UpperTorso:WaitForChild("RightShoulderRigAttachment") :: Attachment,
				WaistRigAttachment = self.Parts.UpperTorso:WaitForChild("WaistRigAttachment") :: Attachment,
			},
			LowerTorso = {
				WaistRigAttachment = self.Parts.LowerTorso:WaitForChild("WaistRigAttachment") :: Attachment,
				LeftHipRigAttachment = self.Parts.LowerTorso:WaitForChild("LeftHipRigAttachment") :: Attachment,
				RightHipRigAttachment = self.Parts.LowerTorso:WaitForChild("RightHipRigAttachment") :: Attachment,
				RootRigAttachment = self.Parts.LowerTorso:WaitForChild("RootRigAttachment") :: Attachment,
			},
			HumanoidRootPart = {
				RootRigAttachment = self.Parts.HumanoidRootPart:WaitForChild("RootRigAttachment") :: Attachment,
			},
			RightUpperArm = {
				RightShoulderRigAttachment = self.Parts.RightUpperArm:WaitForChild("RightShoulderRigAttachment") :: Attachment,
				RightElbowRigAttachment = self.Parts.RightUpperArm:WaitForChild("RightElbowRigAttachment") :: Attachment,
			},
			RightLowerArm = {
				RightElbowRigAttachment = self.Parts.RightLowerArm:WaitForChild("RightElbowRigAttachment") :: Attachment,
				RightWristRigAttachment = self.Parts.RightLowerArm:WaitForChild("RightWristRigAttachment") :: Attachment,
			},
			RightHand = {
				RightWristRigAttachment = self.Parts.RightHand:WaitForChild("RightWristRigAttachment") :: Attachment,
			},
			LeftUpperArm = {
				LeftShoulderRigAttachment = self.Parts.LeftUpperArm:WaitForChild("LeftShoulderRigAttachment") :: Attachment,
				LeftElbowRigAttachment = self.Parts.LeftUpperArm:WaitForChild("LeftElbowRigAttachment") :: Attachment,
			},
			LeftLowerArm = {
				LeftElbowRigAttachment = self.Parts.LeftLowerArm:WaitForChild("LeftElbowRigAttachment") :: Attachment,
				LeftWristRigAttachment = self.Parts.LeftLowerArm:WaitForChild("LeftWristRigAttachment") :: Attachment,
			},
			LeftHand = {
				LeftWristRigAttachment = self.Parts.LeftHand:WaitForChild("LeftWristRigAttachment") :: Attachment,
			},
			RightUpperLeg = {
				RightHipRigAttachment = self.Parts.RightUpperLeg:WaitForChild("RightHipRigAttachment") :: Attachment,
				RightKneeRigAttachment = self.Parts.RightUpperLeg:WaitForChild("RightKneeRigAttachment") :: Attachment,
			},
			RightLowerLeg = {
				RightKneeRigAttachment = self.Parts.RightLowerLeg:WaitForChild("RightKneeRigAttachment") :: Attachment,
				RightAnkleRigAttachment = self.Parts.RightLowerLeg:WaitForChild("RightAnkleRigAttachment") :: Attachment,
			},
			RightFoot = {
				RightAnkleRigAttachment = self.Parts.RightFoot:WaitForChild("RightAnkleRigAttachment") :: Attachment,
				RightFootAttachment = self.Parts.RightFoot:FindFirstChild("RightFootAttachment") :: Attachment,
			},
			LeftUpperLeg = {
				LeftHipRigAttachment = self.Parts.LeftUpperLeg:WaitForChild("LeftHipRigAttachment") :: Attachment,
				LeftKneeRigAttachment = self.Parts.LeftUpperLeg:WaitForChild("LeftKneeRigAttachment") :: Attachment,
			},
			LeftLowerLeg = {
				LeftKneeRigAttachment = self.Parts.LeftLowerLeg:WaitForChild("LeftKneeRigAttachment") :: Attachment,
				LeftAnkleRigAttachment = self.Parts.LeftLowerLeg:WaitForChild("LeftAnkleRigAttachment") :: Attachment,
			},
			LeftFoot = {
				LeftAnkleRigAttachment = self.Parts.LeftFoot:WaitForChild("LeftAnkleRigAttachment") :: Attachment,
				LeftFootAttachment = self.Parts.LeftFoot:FindFirstChild("LeftFootAttachment") :: Attachment,
			},
		}
	end
end

function VRCharacter:Init()
	LocalPlayer.CharacterAdded:Connect(function(_)
		return self:BindCharacter()
	end)

	if LocalPlayer.Character then
		self:BindCharacter()
	end
end

return VRCharacter
