# Deep Down — Roadmap

As of 31 October 2026. The live, editable version (with checkboxes and a drawn overview) is here: <https://claude.ai/artifact/T3z4Nxph7qjtFj5cnJKX1a>

Ten phases from today to launch, each closed by a gate: the game only moves on when the gate's questions get a yes.

## At a glance

| Phase | Focus | Status |
| --- | --- | --- |
| 0 Pre-production | Define the product, prototype the big risks | **In progress** |
| 1 Foundations | Core systems | Started |
| 2 Vertical slice | 20 to 30 minutes at final quality | |
| 3 Steam page | Wishlists and community | |
| 4 Act one | The first half | |
| 5 Act two | The creature, the deep levels | |
| 6 Act three | The ending | |
| 7 Demo | Steam Next Fest | |
| 8 Polish | Finish it | |
| 9 Launch | Release, listen | |

The biggest gates are after the vertical slice (phase 2), where the game has to prove itself to strangers, and after act one (phase 4).

## How to use this roadmap

Tick items as they're done; a phase is finished only when its gate is passed, not when its list is.

- **Gates are honest questions.** If a gate's answer is no, fix it or cut scope before moving on. Building act two on top of an act one that isn't tense wastes months.
- **No dates, on purpose.** This is a part-time project alongside university. Phases are ordered by dependency, not deadlines. Realistically, the whole game is a two-to-three-year project.
- **The scope rule.** Anything new must trace back to a pillar in the design doc. If it doesn't, it waits for after launch.
- **Already done items are ticked**, so the starting point is visible.

## Phase 0 — Pre-production (now)

Define the product completely, and answer the biggest risks with small prototypes, before full development starts.

**Product definition**

- [x] Platform, audience, camera, single-player, business model
- [x] North star, duality principle and five pillars
- [x] Protagonist and emotional arc, ending direction (the white door)
- [x] Setting: invented island mining village, 2010s, 80s and 90s equipment
- [x] History of the mine and the two bloodlines (draft)
- [ ] The elders: who they are, the philosophy each lives by, what each knows (including whether the old branch chief is still alive)
- [ ] The ancients, the guild and the being at the bottom: what really happened
- [ ] The creature: what it is, how it senses, how it behaves, how it links to the being
- [ ] Structure: the three acts, the full list of tales and where each leads, the pacing curve
- [ ] The "wrong" and "wronger" paths: where they branch, what they cost, what they reveal
- [ ] Mechanics list: every system, each tied to a pillar; everything else cut
- [ ] The guild's codex: cipher system design and what the final secret is
- [ ] Art direction: reference board (mines, Sardinian coast, village, light), palette, materials
- [ ] Sound direction: reference board, the sound of each kind of space
- [ ] Scope: what's in the vertical slice, the demo, and version 1.0; asset list
- [ ] Positioning: comparable games, Steam tags, price range, one-line pitch
- [ ] Final title and names (village, island, characters)

**Risk prototypes** (each answers one question)

- [x] Realistic darkness and lantern lighting in Godot (renders look right)
- [ ] Runs at 60 fps at 1080p on archy's RTX 4050
- [ ] Tension: is walking into the dark with only a lantern frightening on its own?
- [ ] Stillness: does holding still and slowing your breath work as a way to survive?
- [ ] Navigation: can players find their way back without a map, using landmarks and chalk?
- [ ] Eye adaptation: do the blinding exit and the dazzling lantern feel real, not annoying?

**Gate:** the design doc answers every question above, and all four feel prototypes get a yes from Gabriel and at least two other people.

## Phase 1 — Foundations

Build the systems everything else stands on, tested in greybox spaces, with no final art yet.

- [x] First-person controller: walk, sprint, crouch, jump, head bob
- [x] Hand lantern with shadows and flicker
- [x] Atmosphere: fog, eye adaptation, surface-to-underground blending
- [x] Flares
- [ ] Interaction: pick up, examine, open, climb ladders, use ropes
- [ ] Inventory with weight and limited space (deciding what to leave behind)
- [ ] Lamp fuel, stamina, breath and heartbeat, injuries
- [ ] Exposure-adaptive presentation: blinding exits, dazzling lantern, interface that adapts
- [ ] Audio foundation: footsteps by surface, reverb that changes with each space, positional sound
- [ ] Save system: statue rooms as save points, home as a save point
- [ ] Dialogue system for the elders, with tales that unlock leads
- [ ] Settings: graphics and performance presets, key rebinding, brightness calibration, subtitles
- [ ] Performance baseline: 60 fps at 1080p on archy, measured in the worst spots

**Gate:** a greybox section can be played start to finish with every system working, at 60 fps on archy.

## Phase 2 — Vertical slice

Build 20 to 30 minutes of the game at final quality: the proof that Deep Down works, and the source for the Steam page and trailer.

- [ ] Scanned, realistic materials: rock, timber, rusted iron, wet surfaces
- [ ] Modular mine kit: tunnel segments, timber sets, junctions, shafts, stope walls
- [ ] Natural cave pieces with real rock shapes
- [ ] One real section of the old workings, with at least one big open space, loops and landmarks
- [ ] Hazards in that section: a rockfall, a pocket of bad air
- [ ] A first slice of Lowmere: the protagonist's home, a few streets, one elder
- [ ] One complete tale: told in the village, leading down, ending in a statue room
- [ ] A first statue room: the statue, a spring, a carving, a codex page
- [ ] Full sound pass for the slice: ambience, footsteps, the mine's voice, the elder's voice
- [ ] Lighting and post-processing tuned on real hardware
- [ ] Playtests with at least five people who've never seen it

**Gate:** testers say it's tense, it looks real, and they want to know what happens next. It runs at 60 fps on archy.

## Phase 3 — Steam page and community

Start collecting wishlists as soon as the slice looks good: wishlists decide how visible the game is at launch, and they take a long time to build.

- [ ] Steamworks account and the one-time app fee ($100, refunded after $1,000 in sales)
- [ ] Capsule art and key art
- [ ] Trailer cut from the vertical slice
- [ ] Store page: description, screenshots, tags, content notice
- [ ] A home for devlogs and short clips (TikTok, YouTube Shorts, a Discord or similar)
- [ ] A rhythm for posting: eerie moments, behind the scenes, the real mines that inspired it
- [ ] Press and creator list: horror YouTubers and streamers who play games like this

**Gate:** the page is live and wishlists grow steadily month to month.

## Phase 4 — Act one

Build the whole first half of the game: the village, the first descent, and the mine as pure environmental horror.

- [ ] The opening: the protagonist's last day, the desperate first descent, the first statue room
- [ ] Lowmere complete: streets, homes, the port and its radio station, the trader, the supplier
- [ ] All the elders of act one, each with their worldview, voice and tales
- [ ] Family scenes: mother, father, sister
- [ ] The resupply economy: finds pay for the ship, and the village reacts when one comes or doesn't
- [ ] Weather on the island, and how it changes the mine (rain, storms, calm)
- [ ] Layer 1, the old workings, complete, with its open spaces and shortcuts
- [ ] Layer 2, the natural caves, as far as act one reaches
- [ ] Act one's tales, statue rooms, carvings and codex pages
- [ ] Tale-linked events: the falling rocks and whispers that echo what elders said
- [ ] Voice recording plan: who voices the elders, which languages

**Gate:** act one plays start to finish, and playtesters finish it wanting to go back down.

## Phase 5 — Act two: the creature and the deep levels

The game turns from environmental horror into creature horror, and goes deeper.

- [ ] The creature's design: look, sound, movement (concept art first, then the model)
- [ ] Its behavior: hunting by sound, stalking, listening, when it appears and when it doesn't
- [ ] Hiding and stillness in practice: breath, heartbeat, hiding spots, silence
- [ ] Its first appearance: the scene that breaks the game's safety
- [ ] Layer 3, the flooded depths: water, tides, cold, the sea gate
- [ ] Layer 4, the ancient tunnels: older than the mine, precise, wrong
- [ ] The "wrong" and "wronger" paths, with their consequences
- [ ] The sealed section and the truth about the disappearances
- [ ] Act two's elders, tales, statue rooms and codex pages
- [ ] The protagonist's family mark found below, and the ancestry slowly understood

**Gate:** testers are afraid of the creature and still curious enough to keep going, and nobody finds the stillness mechanic frustrating.

## Phase 6 — Act three and the ending

The descent to the bottom, the being, the final conversation and the white door.

- [ ] The bottom: the place where the being was imprisoned
- [ ] The human-like being: design, presence, voice
- [ ] The final dialogue, written and rewritten until it lands, ending on the final question
- [ ] The white door scene
- [ ] The codex's final secret, findable only by the most determined players
- [ ] Full read-through of the whole story for the two readings: is the surface clear, and is the depth there?

**Gate:** playtesters finish the game and describe the feeling in the north star: they were there, they were afraid, and something stayed with them.

## Phase 7 — Demo and Steam Next Fest

A free demo of the opening hours, shown during a Steam Next Fest, is one of the strongest wishlist boosts a small game can get.

- [ ] Demo build: from the opening through the first statue room and its tale
- [ ] Demo polish: no crashes, settings menu complete, runs well on modest PCs
- [ ] Sign up for an upcoming Steam Next Fest
- [ ] Send the demo to horror creators before the festival
- [ ] Collect feedback and crash reports, and act on them

**Gate:** the demo gets played, reviewed, and turns players into wishlists.

## Phase 8 — Polish and launch prep

Turn a complete game into a finished one.

- [ ] Bug fixing and full playthroughs from start to end
- [ ] Performance across a range of PCs, not only archy
- [ ] Accessibility: subtitles, brightness and motion options, difficulty of the hiding sections
- [ ] Languages: English and Italian at least
- [ ] Steam features: achievements, cloud saves, Steam Deck check
- [ ] Credits and third-party licenses (CREDITS.md)
- [ ] Support resources in the menu and the content notice on the store page
- [ ] Launch trailer and a release date announced in advance

**Gate:** no known game-breaking bugs, and a full playthrough on a mid-range PC is smooth.

## Phase 9 — Launch and after

Release, listen, and keep the game healthy.

- [ ] Launch on Steam
- [ ] Watch reviews, streams and crash reports closely in the first weeks
- [ ] Quick patches for anything players hit
- [ ] Talk with the community, especially the codex hunters
- [ ] Decide what's next: more languages, consoles, or the co-op mode

**Gate:** the game is out, stable, and players are talking about what it left them with.
