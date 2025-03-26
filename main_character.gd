extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path : String = "parameters/StateMachine/Move/tilt/add_amount"

var run_tilt = 0.0 : set = _set_run_tilt

#@export var blink = true : set = set_blink
#@onready var blink_timer = %BlinkTimer
#@onready var closed_eyes_timer = %ClosedEyesTimer
#@onready var eye_mat = $sophia/rig/Skeleton3D/Sophia.get("surface_material_override/2")
@export var rotation_speed: float = 5.0

#func _ready():
	#blink_timer.connect("timeout", func():
		#eye_mat.set("uv1_offset", Vector3(0.0, 0.5, 0.0))
		#closed_eyes_timer.start(0.2)
		#)
		
	#closed_eyes_timer.connect("timeout", func():
		#eye_mat.set("uv1_offset", Vector3.ZERO)
		#blink_timer.start(randf_range(1.0, 4.0))
		#)

#func set_blink(state : bool):
	#if blink == state: return
	#blink = state
	#if blink:
		#blink_timer.start(0.2)
	#else:
		#blink_timer.stop()
		#closed_eyes_timer.stop()

func _set_run_tilt(value : float):
	run_tilt = clamp(value, -1.0, 1.0)
	animation_tree.set(move_tilt_path, run_tilt)

func idle():
	state_machine.travel("Idle")

func move():
	state_machine.travel("Move")

func fall():
	state_machine.travel("Fall")

func jump():
	state_machine.travel("Jump")

func edge_grab():
	state_machine.travel("EdgeGrab")

func wall_slide():
	state_machine.travel("WallSlide")

#----- CAMERA
#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
#func _process(_delta):
	#rotation.x = clamp(rotation.x, -1, 1)
#
#func _input(event):
	#if event is InputEventMouse and event is not InputEventMouseButton:
		#rotate(Vector3.UP,
			#event.relative.x * -0.005
		#)
		#rotate_object_local(Vector3.RIGHT,
			#event.relative.y * -0.005
		#)
#----------
#

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump()
	elif !is_on_floor() and velocity.y < 0:
		fall()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		move()
		
		var target_rotation = Quaternion(basis.looking_at(direction, Vector3.UP))
		var new_rotation = Quaternion(basis).slerp(target_rotation, rotation_speed * delta)
		basis = Basis(new_rotation)
	elif velocity.y == 0:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		idle()

	move_and_slide()
