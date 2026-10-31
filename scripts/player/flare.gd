class_name Flare
extends RigidBody3D
## A thrown road flare: burns bright red-orange for a while, flickering, then dies out.
## The only way to see the true size of a big cavern.

@export var burn_time: float = 75.0 ## seconds at full strength
@export var fade_time: float = 6.0
@export var light_energy: float = 4.0
@export var light_range: float = 22.0

var _age: float = 0.0
var _noise := FastNoiseLite.new()
var _light: OmniLight3D
var _glow_material: StandardMaterial3D


func _init() -> void:
	mass = 0.3
	continuous_cd = true
	angular_damp = 1.5

	var shape := CylinderShape3D.new()
	shape.radius = 0.025
	shape.height = 0.28
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.rotation.z = PI / 2.0
	add_child(collision)

	var tube := CylinderMesh.new()
	tube.top_radius = 0.025
	tube.bottom_radius = 0.025
	tube.height = 0.28
	tube.radial_segments = 8
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.55, 0.06, 0.04)
	body_material.roughness = 0.6
	var body := MeshInstance3D.new()
	body.mesh = tube
	body.material_override = body_material
	body.rotation.z = PI / 2.0
	add_child(body)

	var tip := SphereMesh.new()
	tip.radius = 0.04
	tip.height = 0.08
	_glow_material = StandardMaterial3D.new()
	_glow_material.albedo_color = Color(1.0, 0.5, 0.4)
	_glow_material.emission_enabled = true
	_glow_material.emission = Color(1.0, 0.25, 0.1)
	_glow_material.emission_energy_multiplier = 8.0
	var glow := MeshInstance3D.new()
	glow.mesh = tip
	glow.material_override = _glow_material
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glow.position = Vector3(0.15, 0, 0)
	add_child(glow)

	_light = OmniLight3D.new()
	_light.light_color = Color(1.0, 0.38, 0.22)
	_light.light_energy = light_energy
	_light.light_volumetric_fog_energy = 1.5
	_light.omni_range = light_range
	_light.omni_attenuation = 1.2
	_light.shadow_enabled = true
	_light.position = Vector3(0.18, 0.06, 0)
	add_child(_light)

	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.seed = randi()


func _process(delta: float) -> void:
	_age += delta
	var strength := 1.0
	if _age > burn_time:
		strength = clampf(1.0 - (_age - burn_time) / fade_time, 0.0, 1.0)
		if strength <= 0.0:
			queue_free()
			return
	# Flares sputter: fast, uneven flicker.
	var flicker := 1.0 + 0.25 * _noise.get_noise_1d(_age * 40.0)
	_light.light_energy = light_energy * strength * flicker
	_glow_material.emission_energy_multiplier = 8.0 * strength * flicker
