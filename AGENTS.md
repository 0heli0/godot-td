# AGENTS.md — godot-td

## Project identity
- **Engine:** Godot 4.7.1-stable, installed at `D:\Godot_v4.7.1-stable`.
- **Language:** GDScript.
- **Genre:** Tower defense.
- **Status:** First playable version is implemented. Project files, autoloads, base scenes, and a resource/economy skeleton exist.

## Verified engine facts
- Engine path: `D:\Godot_v4.7.1-stable\Godot_v4.7.1-stable_win64.exe`.
- This path must be used when running project commands or opening the editor; do not assume `godot` is on `PATH`.

## Game design constraints (from product spec)
- **Spawn points:** top-left, top-center, top-right of the map.
- **Base:** bottom-center of the map.
- **Enemy pathing:** fixed roads; enemies follow predefined routes.
- **Enemy buffs:** 0 or more of defense buff, magic resistance buff, movement speed buff, and health buff.
- **Enemy scaling:** attack power increases with game difficulty and wave number.
- **Player characters:** can be placed on the map, gain experience by killing enemies, and level up (max level 10).
- **Character level milestones:** levels 3, 5, and 8 each unlock one skill.
- **Skill types at each unlock:** physical attack speed, physical attack power, magic attack power, magic cooldown reduction, magic skill activation.
- **Equipment system:** characters can equip weapons.
- **Character promotion:** characters can be upgraded with money; a promoted character receives a new title and restarts at level 1, but unlocks new skills at levels 3, 5, and 8.
- **Resources:** equipment production, wood gathering, ore gathering, and gold collection.
- **Win condition:** defeat all enemy waves.
- **Lose condition:** enemies destroy the player crystal.

## How to work in this repo
- Use GDScript 2 syntax (Godot 4.x).
- Follow Godot scene/script co-location conventions: keep each scene's `.tscn`, `.gd`, and related assets together under a clear folder (e.g., `scenes/enemies/`, `scenes/towers/`, `autoload/`, `resources/`).
- Define shared data (buffs, skills, enemy waves, titles) as `Resource` classes or `JSON` data files so designers can tweak values without editing code.
- Prefer `Node` composition over deep inheritance hierarchies.

## Recommended initialization
If the project does not yet exist:
1. Create `project.godot` with the engine executable above.
2. Add an autoload `GameManager` for global state (wave, money, wood, ore, difficulty).
3. Add an autoload `PathManager` for pre-baked enemy routes.
4. Create base scenes: `Main`, `Map`, `Enemy`, `Tower`, `Projectile`, `BaseCrystal`, `WaveSpawner`, `UIRoot`.

## Assets
- **External asset root:** `D:\projects\godot-td\material\`.
- The project now uses the following categorized Kenney CC0 packs:
  - `tower-defense-top-down/` — tank units used as moving enemies.
  - `kenney_ui-pack/` — buttons, panels, arrows and other UI elements.
  - `kenney_ui-audio/` — click, hover and other UI sounds.
  - `kenney_rpg-audio/` — attack, explosion and other game sounds.
  - `kenney_smoke-particles/` — smoke/explosion particle textures.
- Scenes still use colored polygon placeholders for some game objects; wire sprites from the folders above when replacing visuals.

## Validation
- Open the project from the engine path above.
- Run the project with `F5` (Play) or via command line: `Godot_v4.7.1-stable_win64.exe --path <project-root>`.
- There are no tests yet; add `Gut` or Godot's built-in test runner if automated testing becomes a requirement.
