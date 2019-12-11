local util = {}

sharing = script.Parent

GLOBAL_NAME = "util"

util.services = setmetatable({}, {
	__index = function(self, name)
		local service = game:GetService(name)
		self[name] = service
		return service
	end
})

--

util.get = function(name)
	assert(script:FindFirstChild(name), "no module found for " .. name)
    if (name == script.Name) then return end
    return require(sharing[name])
end

_G[GLOBAL_NAME] = util

return util