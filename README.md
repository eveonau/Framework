
[Network Usage]("https://ffrostfall.github.io/ByteNet/")
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

Use bytenet.
Goodluck.