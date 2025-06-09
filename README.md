
Network Usage - "https://ffrostfall.github.io/ByteNet/"

Access offered through Runner.Network
```luau
  local Runner = require(path.to.framework)
  local Network = Runner.Network
```

Runner usage:

```luau
  local Runner = require(path.to.Framework)

  Runner:ChangeName("Cookie Baking Extravaganza")

  Runner:InitFilesFromParent(game.ReplicatedStorage.Modules)

  --@return Future
  Runner:Init()
  --@return Future
  Runner:Start()
```

Add to wally in your dependencies!
```txt
[dependencies]
Framework = "eveonau/framework@0.1.1"
```

Use bytenet.
Goodluck.