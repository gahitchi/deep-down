# Deep Down

A 2.5D co-op digging adventure for Roblox: dig through a living underground, tame creatures as companions, relight the hidden statues and free the Lumen. (Working title.)

© 2026 Gabriel. All rights reserved — see [LICENSE](LICENSE).

## How the project works

All game code lives in `src/` as plain `.luau` files. [Rojo](https://rojo.space) syncs those files live into Roblox Studio, so the files are the source of truth, not the saved place.

| Folder | Ends up in Studio as | Runs on |
| --- | --- | --- |
| `src/shared` | `ReplicatedStorage.Shared` | both (modules) |
| `src/server` | `ServerScriptService.Server` | server |
| `src/client` | `StarterPlayer.StarterPlayerScripts.Client` | each player |

File names decide script types: `*.server.luau` is a Script, `*.client.luau` is a LocalScript, anything else is a ModuleScript.

## One-time setup (Linux)

1. **Install Rokit**, the toolchain manager:

   ```sh
   curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
   ```

   Restart the terminal afterwards so `rokit` is on your PATH.

2. **Clone the repo and install the tools** (Rojo, Selene, StyLua, at the versions in `rokit.toml`):

   ```sh
   git clone https://github.com/gahitchi/deep-down.git
   cd deep-down
   rokit install
   ```

   Rokit asks you to trust each tool the first time; say yes.

3. **Install the Rojo plugin in Studio.** Download `Rojo.rbxm` from the [Rojo 7.7.1 release](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1). In Studio open the **Plugins** tab, click **Plugins Folder**, drop `Rojo.rbxm` into the folder that opens, and restart Studio. The plugin version must match the `rojo` version in `rokit.toml`.

## Every session

```sh
cd deep-down
git pull
rojo serve
```

Then in Studio: open a **Baseplate** (or our saved place), click **Rojo → Connect** in the Plugins tab, and press **Play**. You should see the build version (for example `Deep Down v0.1.0 (dev)`) in the bottom-left corner and two `[Deep Down]` lines in the Output window.

While `rojo serve` is running, any change to the files (from `git pull` or your editor) appears in Studio within a second.

## Checks

```sh
stylua src        # format
selene src        # lint
rojo build -o deep-down.rbxl   # build a place file without Studio
```

## Design

The game design document lives in Claude Docs: <https://claude.ai/artifact/XUmpncZM4veQo7jxXQfmdG>
