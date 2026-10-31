extends Node3D
## Temporary test level, built from code with placeholder geometry so we can tune lighting and feel
## before real level art exists. Layout, from the surface down:
##   hillside entrance -> timbered adit (side drift left, tall stope right) -> decline ->
##   chamber -> passage -> large natural cavern with an underground lake and a shaft of daylight.

const TUNNEL_WIDTH := 2.8
const TUNNEL_HEIGHT := 2.6
const FLAT_LENGTH := 26.0 ## metres of level tunnel after the entrance
const SLOPE_LENGTH := 28.0 ## metres of descending tunnel
const SLOPE_DEGREES := 14.0
const TIMBER_SPACING := 2.4

# The stope: the tall void left where miners hollowed out an ore vein, off the right side of the adit.
const STOPE_CENTER := Vector3(5.2, 9.0, -18.0)
const STOPE_SIZE := Vector3(8.0, 18.0, 13.0)

# The great cavern, past the chamber.
const CAVERN_CENTER := Vector3(0, 0, -96.0)
const CAVERN_FLOOR_Y := -6.8
const LAKE_CENTER := Vector3(5.0, 0, -104.0)
const LAKE_SIZE := Vector2(26.0, 18.0)
const LIGHT_SHAFT_POSITION := Vector3(7.0, 0, -101.0)

var _rock := Materials.rock()
var _timber := Materials.timber()


func _ready() -> void:
	_build_ground()
	var slope_end := _build_rock_and_tunnels()
	_build_timber_sets(slope_end)
	_build_props()
	_build_stope_details()
	_build_cavern_details()


func _build_ground() -> void:
	var ground := CSGBox3D.new()
	ground.name = "Ground"
	ground.size = Vector3(200, 2, 140)
	ground.position = Vector3(0, -1, 70)
	ground.material = Materials.ground()
	ground.use_collision = true
	add_child(ground)


## Carves the tunnels out of one big block of rock. Returns the floor point where the slope ends.
func _build_rock_and_tunnels() -> Vector3:
	var mountain := CSGCombiner3D.new()
	mountain.name = "Mountain"
	mountain.use_collision = true
	add_child(mountain)

	var mass := CSGBox3D.new()
	mass.name = "RockMass"
	mass.size = Vector3(120, 60, 140)
	mass.position = Vector3(0, -10, -70)
	mass.material = _rock
	mountain.add_child(mass)

	# Level adit from the entrance into the hill.
	_carve_box(mountain, "Adit", Vector3(TUNNEL_WIDTH, TUNNEL_HEIGHT, FLAT_LENGTH + 2.0),
		Transform3D(Basis.IDENTITY, Vector3(0, TUNNEL_HEIGHT / 2.0, -(FLAT_LENGTH / 2.0) + 1.0)))

	# Descending section.
	var slope := deg_to_rad(SLOPE_DEGREES)
	var start := Vector3(0, 0, -FLAT_LENGTH)
	var direction := Vector3(0, -sin(slope), -cos(slope))
	var middle := start + direction * (SLOPE_LENGTH / 2.0)
	var basis := Basis(Vector3.RIGHT, slope)
	var lift := basis * Vector3(0, TUNNEL_HEIGHT / 2.0, 0)
	_carve_box(mountain, "Decline", Vector3(TUNNEL_WIDTH, TUNNEL_HEIGHT, SLOPE_LENGTH + 1.0),
		Transform3D(basis, middle + lift))
	var slope_end := start + direction * SLOPE_LENGTH

	# A natural chamber the miners broke into: wider, taller, irregular.
	var chamber_center := slope_end + Vector3(0, 2.2, -7.0)
	var chamber := CSGSphere3D.new()
	chamber.name = "Chamber"
	chamber.radius = 7.5
	chamber.radial_segments = 18
	chamber.rings = 12
	chamber.operation = CSGShape3D.OPERATION_SUBTRACTION
	chamber.scale = Vector3(1.3, 0.55, 1.0)
	chamber.position = chamber_center
	chamber.material = _rock
	mountain.add_child(chamber)

	# Flatten the chamber floor so it's walkable, and join it to the tunnel.
	_carve_box(mountain, "ChamberLink", Vector3(TUNNEL_WIDTH, TUNNEL_HEIGHT, 4.0),
		Transform3D(Basis.IDENTITY, slope_end + Vector3(0, TUNNEL_HEIGHT / 2.0, -1.5)))
	var floor_fill := CSGBox3D.new()
	floor_fill.name = "ChamberFloor"
	floor_fill.size = Vector3(22, 4, 16)
	floor_fill.position = Vector3(chamber_center.x, slope_end.y - 2.0, chamber_center.z)
	floor_fill.material = _rock
	mountain.add_child(floor_fill)

	# A side drift off the level adit that ends in a collapse: a dead end to explore.
	_carve_box(mountain, "SideDrift", Vector3(12.0, TUNNEL_HEIGHT * 0.9, TUNNEL_WIDTH * 0.9),
		Transform3D(Basis.IDENTITY, Vector3(-6.0, TUNNEL_HEIGHT * 0.45, -14.0)))

	# The stope opens off the right wall of the adit and rises far above it.
	_carve_box(mountain, "Stope", STOPE_SIZE, Transform3D(Basis.IDENTITY, STOPE_CENTER))

	_carve_cavern(mountain, chamber_center)
	return slope_end


## A big natural cavern: overlapping blobs for an irregular shape, a flat floor, a lake basin and a
## crack to the surface that lets a shaft of daylight in.
func _carve_cavern(mountain: CSGCombiner3D, chamber_center: Vector3) -> void:
	var floor_y := CAVERN_FLOOR_Y
	# Passage from the far side of the chamber.
	# Long enough to reach well inside the first blob, so it opens into the cavern instead of
	# meeting its curved wall edge-on.
	_carve_box(mountain, "CavernPassage", Vector3(TUNNEL_WIDTH + 0.6, 3.2, 24.0),
		Transform3D(Basis.IDENTITY, Vector3(chamber_center.x, floor_y + 1.6, chamber_center.z - 17.0)))

	var blobs: Array[Array] = [
		# offset from cavern center, radius, scale
		[Vector3(0, 7.0, 0), 18.0, Vector3(1.35, 0.75, 1.0)],
		[Vector3(-15.0, 5.0, -10.0), 12.0, Vector3(1.0, 0.8, 1.1)],
		[Vector3(15.0, 4.5, 8.0), 10.0, Vector3(1.2, 0.7, 1.0)],
		[Vector3(4.0, 9.0, -12.0), 11.0, Vector3(1.0, 0.9, 1.0)],
	]
	var index := 0
	for blob: Array in blobs:
		var sphere := CSGSphere3D.new()
		sphere.name = "CavernBlob%d" % index
		sphere.radius = blob[1]
		sphere.radial_segments = 20
		sphere.rings = 12
		sphere.scale = blob[2]
		sphere.position = CAVERN_CENTER + Vector3(0, floor_y, 0) + (blob[0] as Vector3)
		sphere.operation = CSGShape3D.OPERATION_SUBTRACTION
		sphere.material = _rock
		mountain.add_child(sphere)
		index += 1

	# Fill the bottoms of the blobs back in to make a walkable floor...
	var cavern_floor := CSGBox3D.new()
	cavern_floor.name = "CavernFloor"
	cavern_floor.size = Vector3(80, 10, 64)
	cavern_floor.position = Vector3(CAVERN_CENTER.x, floor_y - 5.0, CAVERN_CENTER.z)
	cavern_floor.material = _rock
	mountain.add_child(cavern_floor)

	# ...then sink a basin for the lake into it.
	# Shallow, so the clear water shows its stony bottom right below the surface.
	_carve_box(mountain, "LakeBasin", Vector3(LAKE_SIZE.x, 1.6, LAKE_SIZE.y),
		Transform3D(Basis.IDENTITY, Vector3(LAKE_CENTER.x, floor_y - 0.8, LAKE_CENTER.z)))

	# A natural chimney up to the surface, above the lake.
	var chimney := CSGCylinder3D.new()
	chimney.name = "LightShaft"
	chimney.radius = 2.2
	chimney.height = 40.0
	chimney.sides = 10
	chimney.position = LIGHT_SHAFT_POSITION + Vector3(0, 12.0, 0)
	chimney.operation = CSGShape3D.OPERATION_SUBTRACTION
	chimney.material = _rock
	mountain.add_child(chimney)


func _carve_box(parent: Node, part_name: String, size: Vector3, xform: Transform3D) -> void:
	var cut := CSGBox3D.new()
	cut.name = part_name
	cut.size = size
	cut.transform = xform
	cut.operation = CSGShape3D.OPERATION_SUBTRACTION
	cut.material = _rock
	parent.add_child(cut)


## Timber sets: two posts and a cap beam, every few metres, like a real old mine.
func _build_timber_sets(slope_end: Vector3) -> void:
	var sets := Node3D.new()
	sets.name = "TimberSets"
	add_child(sets)

	var z := -1.0
	while z > -FLAT_LENGTH + 1.0:
		_add_timber_set(sets, Transform3D(Basis.IDENTITY, Vector3(0, 0, z)))
		z -= TIMBER_SPACING

	var slope := deg_to_rad(SLOPE_DEGREES)
	var direction := Vector3(0, -sin(slope), -cos(slope))
	var start := Vector3(0, 0, -FLAT_LENGTH)
	var distance := TIMBER_SPACING
	while distance < SLOPE_LENGTH - 1.0:
		# Posts stay vertical on a slope; only their position follows the floor.
		_add_timber_set(sets, Transform3D(Basis.IDENTITY, start + direction * distance))
		distance += TIMBER_SPACING
	# One leaning, half-broken set near the bottom, to make the ceiling feel less trustworthy.
	var broken := Transform3D(Basis(Vector3.FORWARD, deg_to_rad(9.0)), slope_end + Vector3(0, 0, 1.2))
	_add_timber_set(sets, broken, true)


func _add_timber_set(parent: Node3D, xform: Transform3D, broken: bool = false) -> void:
	var post_height := TUNNEL_HEIGHT - 0.25
	var half_width := TUNNEL_WIDTH / 2.0 - 0.18
	for side: float in [-1.0, 1.0]:
		var height := post_height * (0.7 if broken and side > 0.0 else 1.0)
		_add_beam(parent, Vector3(0.22, height, 0.22),
			xform * Transform3D(Basis.IDENTITY, Vector3(side * half_width, height / 2.0, 0)))
	if not broken:
		_add_beam(parent, Vector3(TUNNEL_WIDTH - 0.1, 0.24, 0.26),
			xform * Transform3D(Basis.IDENTITY, Vector3(0, post_height + 0.1, 0)))


func _add_beam(parent: Node3D, size: Vector3, xform: Transform3D) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var beam := MeshInstance3D.new()
	beam.mesh = mesh
	beam.material_override = _timber
	beam.transform = xform
	parent.add_child(beam)


func _build_props() -> void:
	# Rails along the level adit.
	for side: float in [-0.45, 0.45]:
		var rail := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.06, 0.08, FLAT_LENGTH - 1.0)
		rail.mesh = mesh
		var metal := StandardMaterial3D.new()
		metal.albedo_color = Color(0.22, 0.17, 0.13)
		metal.metallic = 0.8
		metal.roughness = 0.7
		rail.material_override = metal
		rail.position = Vector3(side, 0.04, -FLAT_LENGTH / 2.0)
		add_child(rail)

	# The entrance frame: a heavier timber portal set into the hillside.
	var portal := Node3D.new()
	portal.name = "Portal"
	add_child(portal)
	for side: float in [-1.0, 1.0]:
		_add_beam(portal, Vector3(0.35, TUNNEL_HEIGHT + 0.3, 0.35),
			Transform3D(Basis.IDENTITY, Vector3(side * (TUNNEL_WIDTH / 2.0 + 0.05), (TUNNEL_HEIGHT + 0.3) / 2.0, 0.2)))
	_add_beam(portal, Vector3(TUNNEL_WIDTH + 1.0, 0.4, 0.4),
		Transform3D(Basis.IDENTITY, Vector3(0, TUNNEL_HEIGHT + 0.35, 0.2)))


## Old timber work platforms and ladders inside the stope, as the miners left them.
func _build_stope_details() -> void:
	var stope := Node3D.new()
	stope.name = "StopeTimbers"
	add_child(stope)

	var x0 := STOPE_CENTER.x - STOPE_SIZE.x / 2.0
	var x1 := STOPE_CENTER.x + STOPE_SIZE.x / 2.0
	var z0 := STOPE_CENTER.z - STOPE_SIZE.z / 2.0
	var platform_depth := STOPE_SIZE.z * 0.55
	for level: float in [6.0, 12.0]:
		# Platform planks across the back half of the stope, on beams anchored in the walls.
		var platform_z := z0 + platform_depth / 2.0
		_add_static_beam(stope, Vector3(STOPE_SIZE.x, 0.12, platform_depth),
			Transform3D(Basis.IDENTITY, Vector3(STOPE_CENTER.x, level, platform_z)))
		for i: int in 3:
			var z := z0 + 0.4 + i * (platform_depth - 0.8) / 2.0
			_add_beam(stope, Vector3(STOPE_SIZE.x, 0.25, 0.25),
				Transform3D(Basis.IDENTITY, Vector3(STOPE_CENTER.x, level - 0.2, z)))
		# A ladder from the level below.
		var ladder_x := x1 - 1.0
		var ladder_z := z0 + platform_depth + 0.2
		var bottom := level - 6.0
		for side: float in [-0.25, 0.25]:
			_add_beam(stope, Vector3(0.08, 6.4, 0.08),
				Transform3D(Basis.IDENTITY, Vector3(ladder_x + side, bottom + 3.2, ladder_z)))
		var rung := bottom + 0.3
		while rung < level:
			_add_beam(stope, Vector3(0.5, 0.05, 0.05),
				Transform3D(Basis.IDENTITY, Vector3(ladder_x, rung, ladder_z)))
			rung += 0.32
	# A broken plank hanging down from the upper platform.
	_add_beam(stope, Vector3(0.3, 2.6, 0.05),
		Transform3D(Basis(Vector3.RIGHT, deg_to_rad(12.0)), Vector3(x0 + 1.6, 10.8, z0 + platform_depth)))


## The underground lake and the shaft of daylight falling into it.
func _build_cavern_details() -> void:
	var water_mesh := PlaneMesh.new()
	water_mesh.size = LAKE_SIZE
	var water := MeshInstance3D.new()
	water.name = "Lake"
	water.mesh = water_mesh
	var water_material := StandardMaterial3D.new()
	# Dark, mineral-clouded water: you can't see the bottom, which is the point.
	water_material.albedo_color = Color(0.012, 0.018, 0.022)
	water_material.roughness = 0.04
	water_material.metallic_specular = 0.8
	water.material_override = water_material
	water.position = Vector3(LAKE_CENTER.x, CAVERN_FLOOR_Y - 0.45, LAKE_CENTER.z)
	add_child(water)

	# Daylight through the chimney: a narrow, cool beam that the dusty air makes visible.
	var beam := SpotLight3D.new()
	beam.name = "DaylightShaft"
	beam.position = LIGHT_SHAFT_POSITION + Vector3(0, 30.0, 0)
	beam.rotation = Vector3(deg_to_rad(-90.0), 0, 0)
	beam.light_color = Color(0.78, 0.86, 1.0)
	beam.light_energy = 60.0
	beam.light_volumetric_fog_energy = 0.6
	beam.spot_range = 60.0
	beam.spot_angle = 6.0
	beam.spot_attenuation = 0.2
	beam.shadow_enabled = true
	add_child(beam)


## A beam with collision, for things you can stand on.
func _add_static_beam(parent: Node3D, size: Vector3, xform: Transform3D) -> void:
	var body := StaticBody3D.new()
	body.transform = xform
	parent.add_child(body)
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	_add_beam(body, size, Transform3D.IDENTITY)
