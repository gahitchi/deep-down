extends CanvasLayer
## F3 toggles a small overlay with frame rate and lighting state, for tuning performance and the look.

@export var atmosphere: Atmosphere

@onready var _label: Label = $Label


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		visible = not visible


func _process(_delta: float) -> void:
	if not visible:
		return
	var lines := PackedStringArray()
	lines.append("FPS %d" % Engine.get_frames_per_second())
	if atmosphere:
		lines.append("Underground %d%%" % roundi(atmosphere.enclosure * 100.0))
	var camera := get_viewport().get_camera_3d()
	if camera:
		var p := camera.global_position
		lines.append("Position %.1f, %.1f, %.1f" % [p.x, p.y, p.z])
	_label.text = "\n".join(lines)
