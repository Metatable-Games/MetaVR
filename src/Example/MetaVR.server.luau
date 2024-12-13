-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = {
    Version = "1.0.0",

    NexusVRBackpackEnabled = true,
    
    RobloxVRControllerPreviewEnabled = true,
    RobloxVRLaserEnabled = true,

	Menu = {
		KeybindEnabled = true,
		Keybind = Enum.KeyCode.ButtonX,
	},

	Movement = {
		EnabledMovementMethods = {
			"Teleport",
			"SmoothLocomotion",
			"Disabled",
		},

		DefaultMovementMethod = "SmoothLocomotion",
		SnapTeleportBlur = true,

        IKAvatarGesturesEnabled = true,
        IKReplicationRateLimit = 35, -- (30hz with a 5hz buffer for unstable device connections)
	},

	Camera = {
		--If true, Workspace.CurrentCamera.HeadLocked will be locked to false.
		DisableHeadLocked = false,

		--Disables FadeOutViewOnCollision (black screen when in parts).
		DisableFadeOutViewOnCollision = false,

		EnabledCameraOptions = {
			"Default",
			"ThirdPersonTrack",
			"Disabled",
		},
		DefaultCameraOption = "Default",
        MetaVRCameraEnabled = true,
	},
}

local MetaVR = ReplicatedStorage:FindFirstChild("Packages") and require(ReplicatedStorage.Packages:FindFirstChild("MetaVR") or 0000000000).new();
MetaVR:BindConfiguration(Configuration)
MetaVR:Init()