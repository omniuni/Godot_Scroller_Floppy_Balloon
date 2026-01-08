extends Node

@export var s_fade_out: float = 0.7
@export var s_fade_in: float = 0.5

@export var tracks: Dictionary [String, Resource]

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func beep_ui() -> void:
	if not GameSettings.Audio_SFX_Enabled:
		return
	AudioBeeper.beep_background(700, 0.05)
	pass

func play_track(target: String = "") -> void:
	print_debug("Requested to play: " + target)
	var tween_out = create_tween()
	tween_out.tween_property(bgm_player, "volume_db", -80.0, s_fade_out)
	if not GameSettings.Audio_Enabled:
		return
	print_debug("BGM is ON")
	tween_out.finished.connect(func(): _play_string(target))
	pass
	
func _play_string(target: String) -> void:
	bgm_player.stop()
	print_debug("Search in: " + str(tracks))
	if not target.is_empty():
		for key in tracks:
			if key.contains(target):
				var target_resource = tracks[key]
				print_debug("Found matching resource: " + str(target_resource) )
				bgm_player.stream = target_resource
				bgm_player.stream.loop = true
				bgm_player.play()
				var tween_in = create_tween()
				tween_in.tween_property(bgm_player, "volume_db", 0.0, s_fade_in)
	pass
