extends Node2D

@export
var Bump_Horizontal: int = 4
@export
var Bump_Vertical: int = 12 # make negative for "up"
@export
var Bop_Horizontal: int = 1 # make negative for "back"
@export
var Bop_Vertical: int = 5
@export
var Debounce_Rough_Msec: int = 150
@export
var Debounce_Msec_Multiplier: int = 7
@export
var Hit_Ratio: float = .5
@export
var Max_Velocity_Horizontal: int = 260

var generator = RandomNumberGenerator.new()

var bump_debounce: int = 0
var bop_debounce: int = 0

@onready
var body: RigidBody2D = $RigidBodyBalloon
@onready
var balloon: Sprite2D = $RigidBodyBalloon/Balloon

func _ready() -> void:
	balloon.self_modulate = GameSettings.Color_P1
	generator.seed = GameSettings.Seed
	pass

func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("bump"):
		do_bump(event)
	if event_name.to_lower().contains("bop"):
		do_bop(event)
	pass
	
func do_bump(event: InputEvent):
	var horizontal_velocity = body.linear_velocity.x
	var difference = Max_Velocity_Horizontal-horizontal_velocity
	var scale_down = difference/Max_Velocity_Horizontal
	if scale_down > 1:
		scale_down = 1
	if not event.is_echo() and not event.is_released():
		print("Big Bump!")
		body.apply_central_impulse(Vector2i(Bump_Horizontal*scale_down,Bump_Vertical*-1))
		bump_debounce=Debounce_Rough_Msec*Debounce_Msec_Multiplier
	if event.is_echo() and bump_debounce == 0:
		print("Little Bump!")
		body.apply_central_impulse(Vector2i(Bump_Horizontal*scale_down,-1*Bump_Vertical*Hit_Ratio))
		bump_debounce=Debounce_Rough_Msec*generator.randi_range(1,Debounce_Msec_Multiplier)
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
