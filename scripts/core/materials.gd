class_name Materials
extends RefCounted
## Placeholder materials built from procedural noise, so the test mine looks rocky without any downloads.
## They get replaced by scanned PBR textures (Poly Haven / ambientCG) in a later step.


static func rock(base_color: Color = Color(0.36, 0.33, 0.3)) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color
	material.albedo_texture = _noise_texture(0.012, 5, false, _rock_ramp())
	material.roughness = 0.93
	material.normal_enabled = true
	material.normal_texture = _noise_texture(0.03, 6, true)
	material.normal_scale = 1.4
	# Triplanar: textures project from three directions, so any carved shape looks naturally rocky.
	material.uv1_triplanar = true
	material.uv1_triplanar_sharpness = 4.0
	material.uv1_scale = Vector3.ONE * 0.25
	return material


static func ground() -> StandardMaterial3D:
	var material := rock(Color(0.42, 0.45, 0.3))
	material.roughness = 0.97
	material.uv1_scale = Vector3.ONE * 0.12
	return material


static func timber() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.21, 0.14)
	material.roughness = 0.85
	material.normal_enabled = true
	material.normal_texture = _noise_texture(0.08, 3, true)
	material.uv1_triplanar = true
	material.uv1_scale = Vector3.ONE * 0.6
	return material


static func _rock_ramp() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.62, 0.6, 0.58))
	gradient.set_color(1, Color(1.0, 0.97, 0.93))
	gradient.add_point(0.55, Color(0.82, 0.79, 0.75))
	return gradient


static func _noise_texture(frequency: float, octaves: int, as_normal: bool, ramp: Gradient = null) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = frequency
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = octaves
	noise.seed = randi()

	var texture := NoiseTexture2D.new()
	texture.width = 1024
	texture.height = 1024
	texture.seamless = true
	texture.noise = noise
	texture.as_normal_map = as_normal
	if as_normal:
		texture.bump_strength = 10.0
	if ramp:
		texture.color_ramp = ramp
	return texture
