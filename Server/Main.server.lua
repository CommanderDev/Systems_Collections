local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fileSystem = script.Parent

local Sharing = ReplicatedStorage:FindFirstChild("Sharing")

--Sharing
local util = require(Sharing.util)
local get = util.get "get"

get:setFilesystem(fileSystem)

for i,module in next, get "all" do
    coroutine.wrap(function()
        if module.init then
            module:init()
        end
    end)()
end