extends MarginContainer

@onready var ui_pause = $"."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		ui_pause.visible = get_tree().paused
	pass
