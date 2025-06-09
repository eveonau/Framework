-- !strict
-- AcromantuIa, 4/17/2025
-- Framework v0.1

local RunService = game:GetService(`RunService`)
local Future = require(`../Packages/Future`)

local Runner = {
    __files = {},
    Network = require(`../Packages/bytenet`),
    Started = false,
    Initalized = false,
    GAME_NAME = RunService:IsServer() and Instance.new("StringValue", script) or script:WaitForChild("StringValue", 10),
}

local function checkValidFile(requiredFile : {[any]: any}, extra : boolean)
    if type(requiredFile) ~= `table` then
        warn(`[{Runner.GAME_NAME.Value}] File is not a table, cannot require.`)
        return false
    end

    if not requiredFile.ClassName then
        warn(`[{Runner.GAME_NAME.Value}] File does not have a ClassName.`)
        return false
    end

    if extra then

        if not requiredFile.Start or type(requiredFile.start) ~= `function` then
            warn(`[{Runner.GAME_NAME.Value}] File does not have a start function.`)
            return false
        end

        if not requiredFile.Init or type(requiredFile.start) ~= `function` then
            warn(`[{Runner.GAME_NAME.Value}] File does not have a init function.`)
            return false
        end

    end
    return true
end

--(factory) Returns original table with some extra
function Runner.CreateFile(self : Runner, file: {["ClassName"] : string, [any] : any}): {} | nil 
    local ClassName = file.ClassName

    if not checkValidFile(file, false) then return end

    file.__started = false
    file.ClassName = ClassName

    --Led with - to hide functions from the user 
    function file._Start(internalSelf)
        -- local success, reason = Future.Try(function()
            if internalSelf.__started then warn(`[{Runner.GAME_NAME.Value}] Cannot start multiple times.`); return end
            if internalSelf.Start and type(internalSelf.Start) == `function` then
                internalSelf:Start()
            end
    end

    function file._Init(internalSelf)
        local success, reason = Future.Try(function()
            if internalSelf.Init and type(internalSelf.Init) == `function` then
                internalSelf:Init()
            end
        end)

        if not success then
            warn(`[{Runner.GAME_NAME.Value}] Failed to init file {internalSelf.ClassName}: {reason}`)
        end
        return success
    end

    file.__setup = true

    self.__files[ClassName] = file
    return file
end

function Runner:ChangeName(name : string)
    if type(name) ~= `string` then
        warn(`[{Runner.GAME_NAME.Value}] Game name must be a string.`)
        return
    end
    self.GAME_NAME.Value = name
end

function Runner.InitFilesFromParent(self : Runner, Parent : Instance)
    for i,v in Parent:GetDescendants() do
        if v.Name:sub(0, 1) == `_` then continue end
        local a = tick()
        if v:IsA("ModuleScript") then require(v) end
        print(`[${Runner.GAME_NAME.Value}] Required file`, v.Name, "in", math.round(tick() - a), "seconds")
    end
end

function Runner.Init(self : Runner)
    return Future.new(function()
        if self.Initalized then warn(`[{Runner.GAME_NAME.Value}] Cannot initalize multiple times.`); return end
        
        -- if RunService:IsServer() then
        --     for i,v in game.ServerStorage.Modules:GetChildren() do
        --         if v.Name:sub(0, 1) == `_` then continue end
        --         local file = require(v)
        --         file:_Init()
        --         print(`[{Runner.GAME_NAME.Value}]: Initalized file {file.ClassName}`)
        --     end
        -- else
        --     for i,v in game.ReplicatedStorage.Modules:GetChildren() do
        --         if v.Name:sub(0, 1) == `_` then continue end
        --         local file = require(v)
        --         file:_Init()
        --         print(`[{Runner.GAME_NAME.Value}]: Initalized file {file.ClassName}`)
        --     end
        -- end
        for i,v in self.__files do
            local t = tick()
            v:_Init()
            print(`[{Runner.GAME_NAME.Value}]: Initalized file {v.ClassName} after {math.round(tick() - t)}s`)
        end

        self.Initalized = true
        print(`[{Runner.GAME_NAME.Value}]: Initalized all files.`)
    end)
end

function Runner.Start(self : Runner)
    return Future.new(function()
        if not self.Initalized then warn(`[{Runner.GAME_NAME.Value}] Cannot start without intalizing files.`); return end
        if self.Started then warn(`[{Runner.GAME_NAME.Value}] Cannot start multiple times.`); return end

        for i,v in self.__files do
            local t = tick() 
            v:_Start()
            v.__started = true
            print(`[{Runner.GAME_NAME.Value}]: Started file {v.ClassName} after {math.round(tick() - t)}s`)
        end
        self.Started = true
        print(`[{Runner.GAME_NAME.Value}]: Started all {RunService:IsClient() and `client` or `server`} files ✅`)
    end)
end

function Runner.GetModule(self : Runner, key : string)
    --Fast lookup
    if self.__files[key] then
        return self.__files[key]
    end
    --lengthy lookup 
    local Module
    for name, __module in self.__files do
        if name:match(key) then
            Module = __module
        end
    end
    if not Module then warn((`[Runner] Module %s not found in files.`):format(key)); return end
    return Module
end

function Runner.DeepCopy(self : Runner, template, copy)
    for i,v in template do
        if typeof(copy) == `table` then
            copy[i] = {}
            Runner:DeepCopy(v, copy[i])
        else
            copy[i] = v
        end
    end
end

function Runner.WaitForCharacter(self: Runner, player, waiting, iterations)
	task.wait(0.1)
	if player.Character and player.Character:IsDescendantOf(workspace) then
		return player.Character
	else
		for i = 1, (iterations or 500) do
			task.wait(waiting or 0.5)
			if player.Character and player.Character:IsDescendantOf(workspace) then
				return player.Character
			end
		end
	end
	return nil
end

export type Runner = typeof(Runner)
return Runner