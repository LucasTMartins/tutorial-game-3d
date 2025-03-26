extends Camera3D


func _ready() -> void:
	pass



func _process(_delta):

	rotation.x = clamp(rotation.x, -1, 1)



func _input(event):

	if event is InputEventMouse:

		rotate(Vector3.UP,

			event.relative.x * -0.005

		)

		

		rotate_object_local(Vector3.RIGHT,

			event.relative.y * -0.005

		)
