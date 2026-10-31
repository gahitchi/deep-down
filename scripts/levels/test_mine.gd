extends Node3D
## Temporary test level: a hillside with an old mine entrance, a timbered adit that slopes down into
## the dark, and a natural chamber at the end. Built from code with placeholder geometry so we can
## tune the lighting and feel before real level art exists.

const TUNNEL_WIDTH := 2.8
const TUNNEL_HEIGHT := 2.6
const FLAT_LENGTH := 26.0 ## metres of level tunnel after the entrance
const SLOPE_LENGTH := 28.0 ## metres of descending tunnel
const SLOPE_DEGREES := 14.0
const TIMBER_SPACING := 2.4

var _rock := Materials.rock()
var _timber := Materials.timber()


func _ready() -> void:
	_build_ground()
	var slope_end := _build_rock_and_tunnels()
	_build_timber_sets(slope_end)
	_build_props()


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

	return slope_end


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
