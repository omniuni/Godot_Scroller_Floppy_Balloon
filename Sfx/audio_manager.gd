extends Node

func beep_ui() -> void:
	if not GameSettings.Audio_SFX_Enabled:
		return
	AudioBeeper.beep_background(700, 0.05)
	pass
