local sharing = script.Parent

local util = require(sharing.util)

local Event = util.get "Event"
local ReplicatedStorage = util.services.ReplicatedStorage
local RunService = util.services.RunService
local Players = util.services.Players

local networkEvent
local networkFunction

GLOBAL_NAME = "network"

function randomizeName()
	local length = 70
	local numLength = 15
	local RETURN = ""
	for i = 1,length do
		RETURN = RETURN..string.char(math.random(97,122))
	end	
	for i = 1,numLength do
		local num = math.random(1,9)
		RETURN = RETURN.. tostring(num)
	end
	return RETURN
end


local numberOfRemotes = 10
local rEvents = {}
local rFunctions = {}
local tempFunction
local tempFunctionName = "TempFunction"

local madeRemotes = false
local gotRealRemotes =  false

if not madeRemotes and RunService:IsServer() then	--	Need to do the first condition for play solo testing
	tempFunction = Instance.new("RemoteFunction",ReplicatedStorage)
	tempFunction.Name = tempFunctionName
	for i = 1,numberOfRemotes do
		newEvent = Instance.new("RemoteEvent")
		newEvent.Name = randomizeName()
		rEvents[#rEvents+1]=newEvent
		newFunction = Instance.new("RemoteFunction")
		newFunction.Name = randomizeName()
		
		rFunctions[#rFunctions+1]=newFunction
		
		newEvent.Parent = ReplicatedStorage
		newFunction.Parent = ReplicatedStorage
	end
	madeRemotes = true
	local realEventName = math.random(1,numberOfRemotes)
	networkEvent = rEvents[realEventName]
	rEvents[realEventName] = nil
	local realFunctionName = math.random(1,numberOfRemotes)
	networkFunction = rFunctions[realFunctionName]
	rFunctions[realFunctionName] = nil
	
elseif RunService:IsClient() then
	tempFunction = game.ReplicatedStorage:FindFirstChild(tempFunctionName)
	local rEvent,rFunction = tempFunction:InvokeServer("get remotes")
	networkEvent = ReplicatedStorage:FindFirstChild(rEvent)
	networkFunction = ReplicatedStorage:FindFirstChild(rFunction)
end

--

local networkUtil = {}

networkUtil.events = {}	--	[name] = {func, ...}
networkUtil.callbacks = {}

--


if RunService:IsServer() then
	networkEvent.OnServerEvent:Connect(function(playerObject, name, ...)
		if networkUtil.events[name] then
			networkUtil.events[name]:fire(playerObject, ...)
		end
	end)

	networkFunction.OnServerInvoke = function(playerObject, name, ...)
		if networkUtil.callbacks[name] then
			return networkUtil.callbacks[name](playerObject, ...)
		end
	end
	
	tempFunction.OnServerInvoke = function(playerObject,name)
		if gotRealRemotes == false then
			if name == "get remotes" then
				return networkEvent.Name,networkFunction.Name
			end
			gotRealRemotes = true
		else
			playerObject:Kick('Attempt to fetch unauthorized information.')	
		end
	end
	for i,event in pairs(rEvents) do
		event.OnServerEvent:Connect(function(player)
			player:Kick("Attempt to exploit remote event")
		end)
	for i,Function in pairs(rFunctions) do
		Function.OnServerInvoke = function(player)
			player:Kick("Attempt to exploit remote function")
			end
		end
	end
end

if RunService:IsClient() then
	networkEvent.OnClientEvent:Connect(function(name, ...)
		wait()
		if networkUtil.events[name] then
			networkUtil.events[name]:fire(...)
		end
	end)
	
	networkFunction.OnClientInvoke = function(name, ...)
		if networkUtil.callbacks[name] then
			return networkUtil.callbacks[name](...)
		end
	end
end
--

function networkUtil:fireClient(playerObject, name, ...)
	networkEvent:FireClient(playerObject, name, ...)
end

function networkUtil:fireAllClients(name, ...)
	networkEvent:FireAllClients(name, ...)
end

function networkUtil:fireOtherClients(playerObject, name, ...)
	for _, otherPlayerObject in next, Players:GetPlayers() do
		if otherPlayerObject ~= playerObject then
			networkEvent:FireClient(otherPlayerObject, name, ...)
		end
	end
end

function networkUtil:fireServer(name, ...)
	networkEvent:FireServer(name, ...)
end

function networkUtil:invokeClient(playerObject, name, ...)
	return networkFunction:InvokeClient(playerObject, name, ...)
end

function networkUtil:invokeServer(name, ...)
	return networkFunction:InvokeServer(name, ...)
end

function networkUtil:createEventListener(name, func)
	if not self.events[name] then
		self.events[name] = Event.new()
	end
	return self.events[name]:connect(func)
end

function networkUtil:setCallback(name, callback)
	self.callbacks[name] = callback
end

_G[GLOBAL_NAME] = networkUtil

return networkUtil