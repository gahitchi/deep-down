class_name Player
extends CharacterBody3D
## First-person character: walk, sprint, crouch, jump, mouse look and a subtle head bob.
## Esc frees the mouse; clicking the game window captures it again.

@export_group("Movement")
@export var walk_speed: float = 3.2 ## m/s, an unhurried walk
@export var sprint_speed: float = 5.6
@export var crouch_speed: float = 1.6
@export var acceleration: float = 10.0
@export var air_control: float = 0.3
@export var jump_velocity: float = 4.2

@export_group("Look")
@export var mouse_sensitivity: float = 0.0022 ## radians per pixel
@export var max_pitch_degrees: float = 85.0

@export_group("Body")
@export var stand_eye_height: float = 1.62
@export var crouch_eye_height: float = 1.0
@export var stand_height: float = 1.75
@export var crouch_height: float = 1.1

@export_group("Flares")
@export var flares: int = 6 ## how many the player carries
@export var throw_speed: float = 9.0

@export_group("Head bob")
@export var bob_amount: float = 0.035 ## metres of vertical sway at walking speed
@export var bob_frequency: float = 1.9 ## steps per second at walking speed

var _pitch: float = 0.0
var _bob_phase: float = 0.0
var _crouching: bool = false

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera
@onready var _collision: CollisionShape3D = $Collision
@onready var _capsule: CapsuleShape3D = _collision.shape as CapsuleShape3D
@onready var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * mouse_sensitivity)
		_pitch = clampf(
			_pitch - motion.relative.y * mouse_sensitivity,
			-deg_to_rad(max_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)
		_head.rotation.x = _pitch
	elif event.is_action_pressed(&"throw_flare"):
		throw_flare()
	elif event.is_action_pressed(&"ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	_update_crouch(delta)

	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed(&"jump") and not _crouching:
		velocity.y = jump_velocity

	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	var speed := _current_speed()
	var target := direction * speed
	var control := acceleration if is_on_floor() else acceleration * air_control
	velocity.x = lerpf(velocity.x, target.x, 1.0 - exp(-control * delta))
	velocity.z = lerpf(velocity.z, target.z, 1.0 - exp(-control * delta))

	move_and_slide()
	_update_head_bob(delta)


## Lights a flare and throws it where you're looking. Returns it, or null if none are left.
func throw_flare() -> Flare:
	if flares <= 0:
		return null
	flares -= 1
	var flare := Flare.new()
	get_parent().add_child(flare)
	var forward := -_camera.global_basis.z
	flare.global_position = _camera.global_position + forward * 0.5 + Vector3.DOWN * 0.15
	flare.linear_velocity = velocity + (forward + Vector3.UP * 0.25).normalized() * throw_speed
	flare.angular_velocity = Vector3(randf_range(-4, 4), randf_range(-4, 4), randf_range(-4, 4))
	return flare


func _current_speed() -> float:
	if _crouching:
		return crouch_speed
	if Input.is_action_pressed(&"sprint"):
		return sprint_speed
	return walk_speed


func _update_crouch(delta: float) -> void:
	var wants_crouch := Input.is_action_pressed(&"crouch")
	# Only stand back up if there's room above.
	if not wants_crouch and _crouching and _ceiling_blocked():
		wants_crouch = true
	_crouching = wants_crouch

	var target_height := crouch_height if _crouching else stand_height
	_capsule.height = lerpf(_capsule.height, target_height, 1.0 - exp(-12.0 * delta))
	_collision.position.y = _capsule.height / 2.0


func _ceiling_blocked() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	var probe := CapsuleShape3D.new()
	probe.radius = _capsule.radius * 0.9
	probe.height = stand_height
	query.shape = probe
	query.transform = Transform3D(Basis.IDENTITY, global_position + Vector3.UP * (stand_height / 2.0 + 0.05))
	query.exclude = [get_rid()]
	return not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func _update_head_bob(delta: float) -> void:
	var eye_height := crouch_eye_height if _crouching else stand_eye_height
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var moving := is_on_floor() and horizontal_speed > 0.3

	if moving:
		_bob_phase += delta * bob_frequency * TAU * (horizontal_speed / walk_speed)
	var strength := (horizontal_speed / walk_speed) if moving else 0.0
	var bob := sin(_bob_phase) * bob_amount * strength
	var sway := cos(_bob_phase * 0.5) * bob_amount * 0.5 * strength

	var target := Vector3(sway, eye_height + bob, 0.0)
	_head.position = _head.position.lerp(target, 1.0 - exp(-14.0 * delta))
