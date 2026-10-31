# Deep Down — notes for Claude

Roblox game, 2.5D co-op dig-down with taming and light combat. Owner: Gabriel (gahitchi). Proprietary, all rights reserved.

Design doc: https://claude.ai/artifact/XUmpncZM4veQo7jxXQfmdG (read it before designing features).

## Workflow
- Claude writes code here and pushes to `main`; Gabriel runs `rojo serve` on his Arch laptop (Studio via Wine) and playtests.
- Gabriel can't easily paste large logs; ask for the Output window lines that matter.
- Keep each change small and playtestable. Bump `Config.VERSION` when a change is meant to be tested.

## Code conventions
- Luau, `--!strict` at the top of every file.
- Server is authoritative: clients send intent through RemoteEvents, the server validates and changes state. Never trust client values.
- Layout: `src/shared` (modules for both sides), `src/server` (`*.server.luau` + modules), `src/client` (`*.client.luau` + modules).
- One system per module (e.g. `TerrainService`, `DigController`), required from a single entry script per side.
- Format with StyLua (`stylua src`), lint with Selene (`selene src`), and check the place builds (`rojo build -o /tmp/x.rbxl`) before pushing.
- Target players are young and mostly on mobile: big touch targets, at most four on-screen buttons, readable text.
