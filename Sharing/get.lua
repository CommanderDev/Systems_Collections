GLOBAL_NAME = "get"

local get = {}

get.filesystem = nil

function get:getFilesystem()
    return self.filesystem
end

function get:setFilesystem(folder)
    assert(folder:IsA("Folder"), "Filesystem must be a folder")
    self.filesystem = folder
end

local function parsePath(pathString)
    local steps = {}
    for step in pathString:gmatch("[%w_]+") do
        table.insert(steps, step)
    end
    return steps
end

local function navigateSteps(steps, path)
    local object = get:getFilesystem()
    for i = 1, #steps do
        local name = steps[i]
        object = object:FindFirstChild(name)
        if not object then
            error("Item not found in filesystem " .. name .. " (" .. path .. ")" )
        end
    end
    return object
end

local function getReturnValue(object)
    if object:IsA("ModuleScript") then
        return require(object)
    else
        return object
    end
end

local function getAllModules()
    local modules = {}
    for _, module in next, get:getFilesystem():GetDescendants() do
        if module:IsA("ModuleScript") then
            table.insert(modules, getReturnValue(module))
        end
    end
    return modules
end

setmetatable(get, 
    {
        __call = function(self, path)
            if path == "all" then
                return getAllModules()
            else
                local steps = parsePath(path)
                local destination = navigateSteps(steps, path)
                return getReturnValue(destination)
            end
        end
    }
)

_G[GLOBAL_NAME] = get

return get