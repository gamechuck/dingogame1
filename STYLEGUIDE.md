# STYLEGUIDE
version 1.0

## Some important terminology/ideology

Seperation of content and code execution is key here. This is done in following way:

* Ideally the exported game should contain a data-folder alongside the `.exe` and `.pck`.
This is done so any outside person can easily edit stuff like the AI or villager walking
speed without needing acces to Godot and/or the codebase.
* The `controls.JSON` defines all the game's controls OUTSIDE of Godot. Again this is done
as to allow outsiders to edit the controls without needing to re-compile any part of the engine.
* The `CopyAssetFolders.gd` is a stand-alone script that will copy the data-folder and other files to the CI/CD artefact.

## Naming conventions:

**Scenes**: `PascalCase`

Always save in the `*.tscn` format so they are human-readable.

```
EditorCamera.tscn
```

**Scripts**: `PascalCase`

They should be next to their respective scenes and have the same name.

```
EditorCamera.gd
```

**Folders**: `snake_case`

```
editor
godot_project
```

**Assets**: `snake_case`

Assets being images, JSONs, etc...

```
data.json
villager_idle.png
```

**All Functions & variables**: `snake_case`

```swift
var ammo_count : int
get_villager_health()
has_clothes()
```

**Privately-used Functions & variables**: `_*`

Start private functions (will never be used outside of its own script!) with underscore `_`

```swift
var _closest_enemy
func _fetch_closest_enemy()
```

**Constants and enums**: `CAPITAL_SNAKE_CASE`

```swift
enum PLAYER_DIRECTIONS = { UP, DOWN, LEFT, RIGHT }
```

**Class names**: `classPascalCase`

always start with `class` and the rest is `PascalCase`

```swift
class_name classTownBell
```

**Signal names** `snake_case`

Always with verb past tense at the end.

```swift
signal damaged
...
func _on_Player_damaged(damage : float) -> void:
	...
```

**GIT Submodule and repositories**: `kebab-case`

To make submodules stand out, they use kebab-case.

```
ndh-assets
```

## Styling and typing

Put spaces between operators and no spaces around parentheses.

```swift
var a = x + y + (z - abs(w))
```

Initializing arrays:

```swift
var player_spawn_coordinates := [
	Vector2(3, 2),
	Vector2(-12, 4),
	Vector2(7, 0)
]
```

Initializing dictionaries:

```swift
var gun := {
	"ammo": 10,
	"modifiers": [
		{
			"speed": 10,
			"accuracy": 15
		}
		{
			"speed": 30,
			"accuracy": 5
		}
	],
	"name": "My Kickass Gun!"
}
```

Avoid connecting signals and defining groups in the editor for verbosity reasons. Do these in the code.

```swift
class_name classPlayer
extends Node2D

func _ready():
	add_to_group("players")
	$Area2D.connect("area_entered", self, "_on_EnemyChecker_area_entered")

func _on_EnemyChecker_area_entered(area : Area2D) -> void:
	pass

```

Define class names for every multi-instance script.

```swift
class_name classCharacter
```

When inheriting from custom classes, use class name instead of path.

```swift
class_name classVillager
extends classCharacter
```

Maximize the amount of safe lines (make sure line numbers are as green as possible).

Always provide types for variables and return values for functions, even when it's `void`:

```swift
func move_player_to(position : Vector2) -> void:
ex. func _process(delta : float) -> void:
ex. var inventory : Array
# OR
var inventory := []
```

## Folder structure/Project organization

`night-defense-heroes` (kebab-case, since this is a )
- `godot_project` (folder containing the actual godot.project-file)
- `README.md` (The obligatory README-file)
- `STYLEGUIDE.md` (This document)
- `build` (Folder containing the exported game)
- `.gitlab-ci.yml` (YAML for CI/CD, most likely not yet present)

Structure of `godot_project`:

`godot_project`
- `addons` (Godot addons like JSON beautifier.)
- `src` (All scenes and scripts contained in the game.)
- `ndh-assets` (Submodule on which the artist pushes his assets! Don't forget to pull and commit this repo before the main one!)
- `assets`
    - `audio` (All resources for audio)
    - `fonts`
    - `materials`
    - `...` any other necessary asset folders
- `data` (All `*.JSON`, `*.TXT` and other files that we would like to edit AFTER exporting/building the game)

- `default_controls.json` (Default controls for the game in JSON-format, don't use Godot's internal input tool!)
- `default_options.cfg` (Default constants, settings, etc...)
- `default_context.json` (Default game state, such as "Inventory contents, etc...")
- `CopyAssetFolders.gd` (Script for CI/CD exporting, just keep this here.)
- ...and the obvious other scripts.