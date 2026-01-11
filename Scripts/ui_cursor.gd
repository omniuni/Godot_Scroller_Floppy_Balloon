extends Node2D

@onready var sprite: Sprite2D = $CanvasLayer/Sprite2D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pass
	
func _process(_delta: float) -> void:
	sprite.global_position = get_viewport().get_mouse_position()+(sprite.get_rect().size/2)+Vector2(8,8)
	pass

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass
