extends CharacterBody3D

@export var MOUSE_SENSITIVITY :float=0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT:= deg_to_rad (90.0)
@export var CAMERA_CONTROLLER : Camera3D



const SPEED = 50
var DASH = 800
const JUMP_VELOCITY = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _mouse_input: bool = false
var _mouse_rotation : Vector3 
var _rotation_input : float
var _tilt_input : float
var _player_rotation :Vector3
var _camera_rotation :Vector3




func _ready():
	Input.mouse_mode = Input. MOUSE_MODE_CAPTURED

func _input(event) :
	if event.is_action_pressed("exit"):
		get_tree() .quit()

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode ()==Input. MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	print(Vector2(_rotation_input,_tilt_input))

func _update_camera (delta) :
	_mouse_rotation.x+= _tilt_input * delta
	_mouse_rotation.x= clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y+=_rotation_input * delta
	
	_player_rotation=Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation=Vector3(_mouse_rotation.x,0.0,0.0)
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _physics_process(delta):
	# Add the gravity.
	var S=SPEED
	if not is_on_floor():
		velocity.y -= gravity *15* delta
		S=SPEED
	
	_update_camera (delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("dash"):
		S= DASH
	var input_dir = Input.get_vector("move_forward", "move_back", "move_right","move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.z = direction.x * S
		velocity.x = -direction.z * S
	else:
		velocity.x = move_toward(velocity.x, 0, S)
		velocity.z = move_toward(velocity.z, 0, S)

	move_and_slide()
