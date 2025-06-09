# Network Usage:
To be changed with only a single name (`getdata`) instead of a path with folders (`service/getdata`)


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