extends Node

## This script handles the common audio.
## It is autoloaded, so that it persists a single
## instance regardless of the scene.
## This is for both efficiency, and so that UI
## that changes the scene can still emit UI sounds.

@onready
var bgm: AudioStreamPlayer = $bgm

@onready
var mbgm: AudioStreamPlayer = $mbgm

@onready
var hiss: AudioStreamPlayer = $balloon

@onready
var bump: AudioStreamPlayer = $bump

@onready
var bop: AudioStreamPlayer = $bop

var hiss_playing = false

func bgm_start():
	if not GameSettings.Audio_Enabled:
		return
	if not bgm.playing:
		bgm.play()
	pass
	
func bgm_stop():
	if bgm.playing:
		bgm.stop()
	pass
	
func mbgm_start():
	if not GameSettings.Audio_Enabled:
		return
	if not mbgm.playing:
		mbgm.play()
	pass
	
func mbgm_stop():
	if mbgm.playing:
		mbgm.stop()
	pass
	
func hiss_start():
	hiss_playing = true
	hiss_play()
	pass
	
func hiss_play():
	if not GameSettings.Audio_SFX_Enabled or hiss_playing == false:
		return
	if not hiss.playing:
		hiss.play()
	pass
	
func hiss_stop():
	hiss_playing = false
	pass
	
func _on_balloon_finished() -> void:
	hiss_play()
	pass

func bump_play():
	if not GameSettings.Audio_SFX_Enabled:
		return
	bump.play()
	pass
	
func bop_play():
	if not GameSettings.Audio_SFX_Enabled:
		return
	bop.play()
	pass

func play_ui():
	if not GameSettings.Audio_SFX_Enabled:
		return
	AudioBeeper.beep_background(900.0, 0.25)
	pass
