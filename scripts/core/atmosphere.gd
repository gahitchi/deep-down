class_name Atmosphere
extends WorldEnvironment
## The game's look: filmic tonemapping, ambient occlusion, bounce light, glow, volumetric fog and
## slow eye adaptation. It also measures how enclosed the camera is and blends from the open-air
## look to the underground one, so sky light fades out as you go deeper and only your lantern is left.

@export var sun: DirectionalLight3D

@export_group("Surface")
@export var surface_ambient: float = 0.55
@export var surface_fog_density: float = 0.003
@export var surface_fog_albedo: Color = Color(0.8, 0.76, 0.72)
@export var surface_sun_energy: float = 1.3

@export_group("Underground")
@export var underground_ambient: float = 0.0 ## nothing: only real lights exist down here
@export var underground_fog_density: float = 0.018 ## dusty air that turns lamp light into beams
@export var underground_fog_albedo: Color = Color(0.42, 0.4, 0.38)

@export_group("Blending")
@export var probe_length: float = 40.0 ## how far rays look for rock overhead
@export var blend_speed: float = 0.8 ## per second; slow, like eyes and air changing

## 0 = open sky, 1 = fully enclosed by rock. Read by other systems (sound, debug overlay).
var enclosure: float = 0.0

# Directions to probe for rock: straight up plus a ring of steep diagonals.
const PROBE_DIRECTIONS: Array[Vector3] = [
	Vector3(0, 1, 0),
	Vector3(0.5, 1, 0),
	Vector3(-0.5, 1, 0),
	Vector3(0, 1, 0.5),
	Vector3(0, 1, -0.5),
]


func _init() -> void:
	environment = _build_environment()
	camera_attributes = _build_camera_attributes()


func _physics_process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var target := _measure_enclosure(camera)
	enclosure = move_toward(enclosure, target, blend_speed * delta)
	_apply_blend(enclosure)


func _measure_enclosure(camera: Camera3D) -> float:
	var origin := camera.global_position
	var space := camera.get_world_3d().direct_space_state
	var hits := 0
	for direction: Vector3 in PROBE_DIRECTIONS:
		var query := PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * probe_length)
		if not space.intersect_ray(query).is_empty():
			hits += 1
	return float(hits) / PROBE_DIRECTIONS.size()


func _apply_blend(t: float) -> void:
	var env := environment
	env.ambient_light_energy = lerpf(surface_ambient, underground_ambient, t)
	# The sky's share of ambient light leaks through even at zero energy, so fade the share itself:
	# underground, ambient comes only from the (black) ambient color.
	env.ambient_light_sky_contribution = 1.0 - t
	env.volumetric_fog_density = lerpf(surface_fog_density, underground_fog_density, t)
	env.volumetric_fog_albedo = surface_fog_albedo.lerp(underground_fog_albedo, t)
	if sun:
		sun.light_energy = lerpf(surface_sun_energy, 0.0, t)


func _build_environment() -> Environment:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.36, 0.46, 0.62)
	sky_material.sky_horizon_color = Color(0.82, 0.7, 0.58)
	sky_material.ground_horizon_color = Color(0.5, 0.44, 0.38)
	sky_material.ground_bottom_color = Color(0.2, 0.18, 0.16)
	sky_material.sun_angle_max = 20.0

	var sky := Sky.new()
	sky.sky_material = sky_material

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color.BLACK
	env.ambient_light_energy = surface_ambient
	# Sky reflections would make rough rock glow in dark tunnels. Off until reflection probes exist.
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED

	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = 1.0

	env.ssao_enabled = true
	env.ssao_radius = 1.2
	env.ssao_intensity = 2.2
	env.ssil_enabled = true
	env.ssil_intensity = 0.8

	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.04

	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = surface_fog_density
	env.volumetric_fog_albedo = surface_fog_albedo
	env.volumetric_fog_anisotropy = 0.55 # light scatters forward: visible beams from the lantern
	env.volumetric_fog_length = 64.0
	env.volumetric_fog_gi_inject = 0.6
	return env


func _build_camera_attributes() -> CameraAttributesPractical:
	var attributes := CameraAttributesPractical.new()
	# Eye adaptation: bright daylight is toned down, darkness is brightened only slightly (never
	# enough to see without a light), and the change happens slowly, like real eyes.
	attributes.auto_exposure_enabled = true
	attributes.auto_exposure_min_sensitivity = 60.0
	attributes.auto_exposure_max_sensitivity = 140.0
	attributes.auto_exposure_speed = 0.35
	attributes.auto_exposure_scale = 0.3
	return attributes
