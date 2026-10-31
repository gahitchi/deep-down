class_name Lantern
extends Node3D
## A hand-held oil lantern: warm light with soft shadows, a gentle flame flicker and a slight lag behind
## the camera so it feels held, not glued to the screen. F toggles it.

@export var light_energy: float = 1.6
@export var flicker_strength: float = 0.12 ## fraction of energy the flame wavers by
@export var flicker_speed: float = 7.0
@export var sway_lag: float = 10.0 ## higher = follows the camera more tightly

var _noise := FastNoiseLite.new()
var _time: float = 0.0
var _rest_transform: Transform3D

@onready var _light: OmniLight3D = $Light
@onready var _glass: MeshInstance3D = $Glass


func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 1.0
	_noise.seed = randi()
	_rest_transform = transform
	# Lag is applied in global space, so start where the parent puts us.
	top_level = true
	global_transform = _target_transform()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_lantern"):
		visible = not visible


func _process(delta: float) -> void:
	_time += delta
	global_transform = global_transform.interpolate_with(_target_transform(), 1.0 - exp(-sway_lag * delta))

	if not visible:
		return
	# Two layers of noise: slow breathing of the flame plus quick small flickers.
	var slow := _noise.get_noise_1d(_time * flicker_speed * 0.15)
	var fast := _noise.get_noise_1d(1000.0 + _time * flicker_speed)
	var flicker := 1.0 + flicker_strength * (0.7 * slow + 0.3 * fast)
	_light.light_energy = light_energy * flicker
	var glass_material := _glass.get_active_material(0) as StandardMaterial3D
	if glass_material:
		glass_material.emission_energy_multiplier = flicker


func _target_transform() -> Transform3D:
	var parent := get_parent() as Node3D
	return parent.global_transform * _rest_transform
