--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Classes: Folder = script:WaitForChild("Classes")
local Packages: Folder = script:WaitForChild("Packages")

local LatestVersion: string = "1.0.0"

local MetaVR = {
	Server = {
		Configuration = {},
		Inited = false,
	},

	Client = {},
}

MetaVR.__index = MetaVR
MetaVR.Server.__index = MetaVR.Server
MetaVR.Client.__index = MetaVR.Client

export type MetaVR = {} & typeof(setmetatable({}, MetaVR))

function MetaVR.new(): MetaVR
	if RunService:IsServer() then
		return setmetatable({}, MetaVR.Server)
	else
		return setmetatable({}, MetaVR.Client)
	end
end

-- ///////////////////////////////////// Server ///////////////////////////////////// --

function MetaVR.Server:Init()
	assert(not self.Inited, "MetaVR: Is already initialized.")
	assert(
		self.Configuration ~= nil,
		"MetaVR: Configuration is not set. Please set it using MetaVR:BindConfiguration(Configuration)"
	)

	self.IKAvatarGestures = require(Classes:WaitForChild("IKAvatarGestures")).new(self)

    if self.Configuration.Movement.IKAvatarGesturesEnabled then
        self.IKAvatarGestures:Init()
    end

	if self.Configuration.NexusVRBackpackEnabled then
		(require(10728805649) :: any)()
	end

	self.Inited = true
	warn("MetaVR: Server Initialized!")
end

function MetaVR.Server:BindConfiguration(Configuration)
	if not script:FindFirstChild("MetaConfiguration") then
		local MetaConfiguration = Instance.new("StringValue")
		MetaConfiguration.Name = "Configuration"
		MetaConfiguration.Parent = script
	end

	script:FindFirstChild("MetaConfiguration").Value = HttpService:JSONEncode(Configuration)
	script:FindFirstChild("MetaConfiguration"):AddTag("ConfigurationReady")
	self.Configuration = Configuration

	if self.Configuration.Version ~= LatestVersion then
		warn("MetaVR: The configuration version is not up to date. Please update it to the latest version.")
	end
end

-- ///////////////////////////////////// Client ///////////////////////////////////// --

function MetaVR.Client:Init()
	assert(not self.Inited, "MetaVR: Is already initialized.")

	-- Wait for the string value to be created
	if not script:FindFirstChild("MetaConfiguration") then
		repeat
			task.wait(0.1)
		until script:FindFirstChild("MetaConfiguration")
	end

	-- Wait for the string value to be set
	if not script.MetaConfiguration:HasTag("ConfigurationReady") then
		repeat
			task.wait(0.1)
		until script.MetaConfiguration:HasTag("ConfigurationReady")
	end

	self.Configuration = HttpService:JSONDecode(script:FindFirstChild("MetaConfiguration").Value)

	self.VRCamera = require(Classes:WaitForChild("VRCamera")).new(self)
	self.IKAvatarGestures = require(Classes:WaitForChild("IKAvatarGestures")).new(self)

    if self.Configuration.Movement.IKAvatarGesturesEnabled then
        self.IKAvatarGestures:Init()
    end

	self.Inited = true
	warn("MetaVR: Client Initialized!")
end

return MetaVR