# Deep Down — notes for Claude

First-person, single-player horror game in Godot 4.7 (Forward+, Jolt physics), for Steam. Owner: Gabriel (gahitchi). Proprietary, all rights reserved.

Design doc (read before designing features): https://claude.ai/artifact/Qzxnq9YQ5ByK6qZw1ZnAFZ
Roadmap (live): https://claude.ai/artifact/T3z4Nxph7qjtFj5cnJKX1a — snapshot in `docs/ROADMAP.md`.
The Roblox prototype that came before is on the `archive/roblox-prototype` branch; it's history, not a reference for this code.

## Direction in one paragraph
Grounded horror in the abandoned deep workings of a mine on a remote mountainous island (inspired by Sardinia's mining coast, changeable weather), below a dying village in the 2010s that runs on 80s and 90s equipment. No combat. Environmental horror in act one; a strange creature arrives mid-game. Realism is a priority: lighting and presentation that behave like real eyes, realistic materials, real mining logic in level design, big open spaces as well as tunnels. The story is personal and existential (duality of surface and depth; Buddhist, existentialist and nihilist ideas voiced by different elders), never preached.

## Current phase
Pre-production (roadmap phase 0): defining the product before more code. Don't start new features unless Gabriel asks.

## Workflow
- Claude writes code and scenes here and pushes to `main`; Gabriel pulls and plays on his Arch laptop (RTX 4050). Performance target: 1080p 60 fps there.
- Before pushing, run the headless checks below. For anything visual, render screenshots and look at them.
- Keep changes small and playable. Bump `config/version` in `project.godot` when a build is meant to be tested.

## Checks (Godot 4.7.2 binary in the scratchpad tools folder, or `godot` on PATH)
- Import: `godot --headless --path . --import`
- Script check: `godot --headless --path . --check-only --script <file.gd>`
- Smoke run: `godot --headless --path . --quit-after 300` (should print nothing but the version line)
- Screenshots: `VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1280x720 --windowed --script res://tools/screenshots.gd -- <out_dir>` (needs `xvfb` and `mesa-vulkan-drivers`; about a minute per shot on software Vulkan)

## Code conventions
- GDScript with static types everywhere (`var x: float`, typed arrays, `:=` where the type is obvious).
- One responsibility per script; `class_name` for reusable types.
- Build simple scenes in `.tscn` by hand; generate repetitive placeholder geometry in code.
- Comments explain why, in plain words. Doc comments (`##`) on scripts and exported properties.
- Lighting gotcha: sky ambient light leaks even at zero energy. Underground darkness relies on fading `ambient_light_sky_contribution` to 0 (see `atmosphere.gd`).
