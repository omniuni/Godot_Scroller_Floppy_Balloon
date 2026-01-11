extends Node2D

func _ready() -> void:
	Input.set_use_accumulated_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pass

func _input(event):
	if event is InputEventMouseMotion:
		position = event.position
	pass

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass
