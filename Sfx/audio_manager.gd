extends Node

@onready var beep_ui: AudioStreamPlayer = $beep_ui
var beep_ui_playback: AudioStreamGeneratorPlayback

var pulse_hz = 440.0
var phase = 0.0
var hz = 0
var frames_left = 0

func _ready() -> void:
	
	#start the beep_ui
	hz = beep_ui.stream.mix_rate
	beep_ui.play()
	beep_ui_playback = beep_ui.get_stream_playback()
	beep_ui.stop()
	
	pass
	
func _process(delta: float) -> void:
	if beep_ui.playing:
		generate()
	pass
	
func beep(frequency_hz, time_seconds) -> void:
	frames_left = hz * time_seconds
	pulse_hz = frequency_hz
	beep_ui.play()
	beep_ui_playback = beep_ui.get_stream_playback()
	generate()
	pass
	
func generate() -> void:
	var increment: float = pulse_hz / hz
	var frames_available: int = beep_ui_playback.get_frames_available() # check how many frames we can fill
	frames_left-=frames_available
	for i in range(frames_available):
		beep_ui_playback.push_frame(Vector2.ONE * sin(phase * TAU))
		phase = fmod(phase + increment, 1.0)
	if frames_left <= 0:
		beep_ui.stop()
	pass
