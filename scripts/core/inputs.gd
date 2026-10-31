extends Node
## Registers the game's default controls at startup.
## Defined in code so they're easy to read and change; a rebinding menu can come later.

const KEY_BINDINGS: Dictionary[StringName, Array] = {
	&"move_forward": [KEY_W, KEY_UP],
	&"move_back": [KEY_S, KEY_DOWN],
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"jump": [KEY_SPACE],
	&"sprint": [KEY_SHIFT],
	&"crouch": [KEY_CTRL, KEY_C],
	&"toggle_lantern": [KEY_F],
	&"toggle_debug": [KEY_F3],
}


func _ready() -> void:
	for action: StringName in KEY_BINDINGS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for keycode: Key in KEY_BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)
