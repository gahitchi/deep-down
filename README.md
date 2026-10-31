# Deep Down

A first-person horror game about a dying mountain village, an abandoned mine, and the old tales that lead deeper into it than anyone should go. Built with Godot 4, for PC (Steam). Working title.

© 2026 Gabriel. All rights reserved — see [LICENSE](LICENSE).

Design document: <https://claude.ai/artifact/Qzxnq9YQ5ByK6qZw1ZnAFZ>
Roadmap: [docs/ROADMAP.md](docs/ROADMAP.md) (live version: <https://claude.ai/artifact/T3z4Nxph7qjtFj5cnJKX1a>)

## Run it

1. Install **Godot 4.7.2** (standard build, not .NET). On Arch, `sudo pacman -S godot` works if the repo version is 4.7.x; otherwise download the Linux build from <https://godotengine.org/download>.
2. Clone and open:

   ```sh
   git clone https://github.com/gahitchi/deep-down.git
   ```

   In Godot's Project Manager, click **Import**, pick `deep-down/project.godot`, then **Import & Edit**. The first import takes a minute.
3. Press **F5** (or the play button, top right) to run the test level.

## Controls

| Action | Key |
| --- | --- |
| Move | WASD or arrows |
| Look | Mouse |
| Sprint | Shift |
| Crouch | Ctrl or C |
| Jump | Space |
| Lantern on/off | F |
| Throw a flare (6 carried) | G |
| Debug overlay (FPS, lighting) | F3 |
| Free the mouse | Esc (click to capture it again) |

## Project layout

| Folder | What's in it |
| --- | --- |
| `scenes/` | Godot scenes: `player/`, `levels/` |
| `scripts/` | GDScript, by area: `core/` (input, atmosphere, materials), `player/`, `levels/`, `ui/` |
| `tools/` | Developer tools, such as the screenshot script |

## What exists so far

- First-person character: walk, sprint, crouch (won't stand up under a low ceiling), jump, head bob.
- Hand lantern with soft shadows, flame flicker and a slight lag behind the camera.
- Atmosphere that blends from open air to underground as rock closes in overhead: the sky light fades out, the air gets dusty (volumetric fog), and your eyes adapt slowly.
- Throwable flares that light up big spaces for over a minute.
- A temporary test level, all placeholder geometry and procedural textures: a mine entrance, a timbered tunnel with a side drift and a tall stope (old platforms and ladders), a decline, a chamber, and a large natural cavern with an underground lake and a shaft of daylight.
