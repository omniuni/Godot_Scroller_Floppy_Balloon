extends RigidBody2D

@export
var Bump_Horizontal: int = 2
@export
var Bump_Vertical: int = 15 # make negative for "up"
@export
var Bop_Horizontal: int = 1 # make negative for "back"
@export
var Bop_Vertical: int = 5
@export
var Debounce_Rough_Msec: int = 100
@export
var Hit_Ratio: float = 0.6

var bump_debounce: int = 0
var bop_debounce: int = 0

@onready
var balloon: Sprite2D = $Balloon

func _ready() -> void:
	balloon.self_modulate = GameSettings.Color_P1
	pass

func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("bump"):
		do_bump(event)
	if event_name.to_lower().contains("bop"):
		do_bop(event)
	pass
	
func do_bump(event: InputEvent):
	print("do_bump")
	print("bump_debounce "+str(bump_debounce))
	if not event.is_echo():
		print("Big Bump!")
		apply_central_impulse(Vector2i(Bump_Horizontal,Bump_Vertical*-1))
		bump_debounce=Debounce_Rough_Msec
	if event.is_echo() and bump_debounce == 0:
		print("Little Bump!")
		apply_central_impulse(Vector2i(Bump_Horizontal,-1*Bump_Vertical*Hit_Ratio))
		bump_debounce=Debounce_Rough_Msec
	pass
	
func do_bop(event: InputEvent):
	
	pass


func _on_debouncer_timeout() -> void:
	if bump_debounce > 0:
		bump_debounce-=50
	if bump_debounce < 0:
		bump_debounce = 0
	if bop_debounce > 0:
		bop_debounce-=50
	if bop_debounce < 0:
		bop_debounce = 0
	pass
