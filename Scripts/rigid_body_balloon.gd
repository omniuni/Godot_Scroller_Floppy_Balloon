extends RigidBody2D

@onready
var balloon: Sprite2D = $Balloon

func _ready() -> void:
	balloon.self_modulate = GameSettings.Color_P1
	pass

func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("ball"):
		do_jump()
	pass
	
func do_jump():
	print("JUMP")
	apply_central_impulse(Vector2i(2,-20))
	pass
