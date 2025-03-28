extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#----- CAMERA
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	rotation.x = clamp(rotation.x, -1, 1)

func _input(event):
	if event is InputEventMouse and event is not InputEventMouseButton:
		rotate(Vector3.UP,
			event.relative.x * -0.005
		)
		rotate_object_local(Vector3.RIGHT,
			event.relative.y * -0.005
		)
#----------

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
