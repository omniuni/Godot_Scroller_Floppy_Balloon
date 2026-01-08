extends Control

func _ready() -> void:
	GameSettings.apply_display()
	# No way to "Exit" on the web.
	var button_exit: Button = $MarginContainer/VBoxContainer/VBoxOptions/ButtonExit
	button_exit.visible = OS.get_name() != "Web"
	AudioManager.play_track("menu")
	pass

func _on_button_notes_pressed() -> void:
	AudioManager.beep_ui()
	Scenes.change_to(get_tree(), Scenes.app)
	pass

func _on_button_settings_pressed() -> void:
	AudioManager.beep_ui()
	Scenes.change_to(get_tree(), Scenes.settings)
	pass
	
func _on_button_help_about_pressed() -> void:
	AudioManager.beep_ui()
	Scenes.change_to(get_tree(), Scenes.help)
	pass

func _on_button_exit_pressed() -> void:
	AudioManager.beep_ui()
	Scenes.quit(get_tree())
	pass

func _notification(notification_int: int) -> void:
	if notification_int == NOTIFICATION_EXIT_TREE:
		Beeper.mbgm_stop()
	pass
