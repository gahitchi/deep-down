extends SceneTree
## Dev tool: loads the test level, places the player at a few spots and saves screenshots.
## Run with: godot --path . --script res://tools/screenshots.gd -- <out_dir>
## (works headless on a GPU-less machine with xvfb-run and a software Vulkan driver)

const SHOTS := [
	# name, player position, yaw degrees, pitch degrees
	["01_outside", Vector3(0, 0.1, 12), 0.0, 4.0],
	["02_entrance", Vector3(0, 0.1, 1.5), 0.0, 0.0],
	["03_adit", Vector3(0, 0.1, -12), 0.0, -4.0],
	["04_decline", Vector3(0, 0.1, -26.5), 0.0, -14.0],
	["05_chamber", Vector3(0, -6.6, -55.5), 15.0, 2.0],
]
const SETTLE_FRAMES := 70

var _level: Node
var _player: CharacterBody3D
var _shot_index := 0
var _frame := 0
var _out_dir := "/tmp"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out_dir = args[0]
	_level = (load("res://scenes/levels/test_mine.tscn") as PackedScene).instantiate()
	root.add_child(_level)
	_player = _level.get_node("Player") as CharacterBody3D
	# Settle faster than in play: we only care about the end state of each spot.
	var atmosphere := _level.get_node("Atmosphere") as WorldEnvironment
	atmosphere.set("blend_speed", 5.0)
	(atmosphere.camera_attributes as CameraAttributesPractical).auto_exposure_speed = 4.0
	_place(SHOTS[0])


func _place(shot: Array) -> void:
	_player.global_position = shot[1]
	_player.velocity = Vector3.ZERO
	_player.rotation.y = deg_to_rad(shot[2])
	(_player.get_node("Head") as Node3D).rotation.x = deg_to_rad(shot[3])


func _process(_delta: float) -> bool:
	_frame += 1
	var shot: Array = SHOTS[_shot_index]
	# Keep the player pinned so physics doesn't drift during settling.
	_player.global_position = shot[1]
	_player.velocity = Vector3.ZERO
	if _frame < SETTLE_FRAMES:
		return false
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [_out_dir, shot[0]]
	image.save_png(path)
	var atmo := _level.get_node("Atmosphere") as WorldEnvironment
	var sun := _level.get_node("Sun") as DirectionalLight3D
	print("saved ", path, " | enclosure=", atmo.get("enclosure"), " sun=", sun.light_energy,
		" ambient=", atmo.environment.ambient_light_energy, " fog=", atmo.environment.volumetric_fog_density)
	_frame = 0
	_shot_index += 1
	if _shot_index >= SHOTS.size():
		return true
	_place(SHOTS[_shot_index])
	return false
