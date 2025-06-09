-- !strict
-- AcromantuIa
-- 4/17/2025

--[[
    Network library for handling remote events and functions
    ```luau
    Path format: FolderName/RemoteName

  --Constructs a remote event, flag for unrelaible (when true)
    • ConstructEvent(path, unrealiable?): (callback: (Player, ...) -> ()) | false 
  --Usage:
    local Ev = Network:ConstructEvent("Documentation/ExampleRemote", false))
    Ev(function(player: Player, param1)
        print(player.Name, " sent ", param1)
    end)

  --Constructs a remote function
    • ConstructFunction(path): false = failed 
  --Usage:  
    local Func = Network:ConstructFunction("Documentation/ExampleFunction")


  --Server/Client methods function with the same methods 
  --Connects to a remote event
    • ConnectEvent(path, func : ()): RBXScriptSignal 
    --Usage:
    Network:ConnectEvent("Documentation/ExampleRemote", function(player: Player, param1)
        print(player.Name, " sent ", param1)
    end)

  --Connects to a remote function
    • ConnectFunction: Connects to a remote function
    Network:ConnectFunction("Documentation/ExampleFunction", function(player: Player, ...)
        -- Do something with the player and arguments
        return true
    end)

  --Returns a remote event/function
    • GetEvent(path)
  --Usage:
    local Event = Network:GetEvent("Documentation/ExampleRemote")
    ```
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()

local Network = {
	ClassName = "Network",
    Events = {}
}

local function getPathFromString(str : string): Instance | false
    local Parent, child = unpack(string.split(str, "/"))

    if Parent == nil or child == nil then warn(`Bad input (ParentFolder/RemoteName) expected. Recieved: {str}`); return false end

    if ReplicatedStorage.Events:FindFirstChild(Parent) and ReplicatedStorage.Events[Parent]:FindFirstChild(child) then
        return ReplicatedStorage.Events[Parent][child]
    end

    warn(`[{IsClient and "Client" or "Server"}]: Network library failed to find remote {str}`)
    return false
end

local function constructEvent(unreliable : boolean)
   return unreliable and Instance.new("UnreliableRemoteEvent") or Instance.new("RemoteEvent")
end

--@brief ctors remote event (reliable by default, Construct remote first if you want unreliable) Returns connection for cleanup, not handled here
function Network.ConnectEvent(self : Network,  path: string, callback: (any) -> ()): ()
    local Event = getPathFromString(path)
    if not Event and IsClient then warn(`[Network] Remote {path} not found on client, returning.`); return else
        Event = self:ConstructEvent(path, false)
    end

    if IsClient then
        Event.OnClientEvent:Connect(callback)
    else
        Event.OnServerEvent:Connect(callback)
    end
    return false
end

function Network.GetFunction(self: Network, path: string): Instance | false
    return getPathFromString(path)
end

function Network.GetEvent(self: Network, path: string): Instance | false
    return getPathFromString(path)
end

function Network.FireServer(self: Network, path: string, ...)
    local Event = getPathFromString(path)
    if IsClient then
        if Event and Event:IsA("RemoteEvent") then
            Event:FireServer(...)
        else
            warn(`[Network] Cannot fire remote {path} on client, returning.`)
        end
    else
        if Event and Event:IsA("RemoteEvent") then
            Event:FireAllClients(...)
        else
            warn(`[Network] Cannot fire remote {path} on server, returning.`)
        end
    end
end

function Network.FireClient(self: Network, path: string, player : Player,  ...)
    local Event = getPathFromString(path)
    if IsClient then
       warn(`[Network] Cannot fire remote {path} on client, returning.`)
        return
    else
        if Event and Event:IsA("RemoteEvent") then
            Event:FireAllClients(...)
        else
            warn(`[Network] Cannot fire remote {path} on server, returning.`)
        end
    end
end

function Network.FireAllClients(self: Network, path: string, ...)
    local Event = getPathFromString(path)
    if IsClient then
        warn(`[Network] Cannot fire remote {path} on client, returning.`)
        return
    else
        if Event and Event:IsA("RemoteEvent") then
            Event:FireAllClients(...)
        else
            warn(`[Network] Cannot fire remote {path} on server, returning.`)
        end
    end
end

--ctors remote func
function Network.ConnectFunction(self: Network, path: string, callback: (T: Player, ...any) -> ()): ()
    local Event = getPathFromString(path)

    if not Event and IsClient or (typeof(Event) == "Instance" and not Event:IsA("RemoteFunction")) then return else
        self:ConstructFunction(path)
        Event = getPathFromString(path)
    end

    if not Event or typeof(Event) == "Instance" and not Event:IsA("RemoteFunction") then return end

    if IsClient then
        Event.OnClientInvoke = callback
    else
        Event.OnServerInvoke = callback
    end
end


--Constructs (folder) if not found
local function checkPath(path): boolean
    local split = string.split(path, '/')
    if ReplicatedStorage.Events:FindFirstChild(split[1]) then return true
    elseif (not IsClient) and #split > 1 then
       local folder = Instance.new("Folder")
       folder.Name = split[1]
       folder.Parent = ReplicatedStorage.Events
       return true
    end
    return false
end

function Network.ConstructEvent(self: Network, path: string, unreliable : boolean | nil)
    if IsClient then warn("Network:ConstructEvent() Cannot ctor events on the client (Use other method) (TODO write local events function)"); return end
	--create remote on server
    checkPath(path)

    local Parent, child = unpack(string.split(path, "/"))

    if ReplicatedStorage.Events[Parent]:FindFirstChild(child) then return ReplicatedStorage.Events[Parent][child]
    else
        local Event = constructEvent(unreliable or false)
        Event.Name = child

        Event.Parent = ReplicatedStorage.Events[Parent]
    end

    return function(callback : (T: Player, ...any) -> ())
        self:ConnectEvent(path, callback)
    end
end

--ctors remote func
function Network.ConstructFunction(self: Network, path: string): ()
    checkPath(path)
    local Parent, child = unpack(string.split(path, "/"))

	if ReplicatedStorage.Events[Parent]:FindFirstChild(child) then return ReplicatedStorage.Events[Parent][child]
    else
        local Event = Instance.new("RemoteFunction")
        Event.Name = child
        Event.Parent = ReplicatedStorage.Events[Parent]
    end

    local flag = false
    return function(callback : (T: Player, ...any) -> ()) 
        if flag then return end 
        flag = true
        self:ConnectFunction(path, callback)
    end
end

export type Network = typeof(Network)
return Network