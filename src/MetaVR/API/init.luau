--!strict
-- Copyright (c) 2024 Metatable Games, all rights reserved.
-- Meta VR: A Roblox virtual reality framework.

-- License: MIT
-- GitHub: https://github.com/Metatable-Games/MetaVR

local API = {}
API.__index = API

export type API = {
    new: () -> API,
} & typeof(setmetatable({}, API))

function API.new(): API
    return setmetatable({}, API)
end

return API