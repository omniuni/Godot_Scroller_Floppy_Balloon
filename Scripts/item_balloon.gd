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

@export
var Max_Life: float = 300
@export
var Current_Life: float = 300

signal balloon_life(life: float)

var generator = RandomNumberGenerator.new()

var bump_debounce: int = 0
var bop_debounce: int = 0

@onready
var balloon_container: Node2D = $"."
@onready
var balloon_body: RigidBody2D = $RigidBodyBalloon
@onready
var balloon: Sprite2D = $RigidBodyBalloon/Balloon

func _ready() -> void:
	balloon.self_modulate = GameSettings.Color_P1.lightened(0.2)
	generator.seed = GameSettings.Seed
	balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
	pass

func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("bump"):
		do_bump(event)
	if event_name.to_lower().contains("bop"):
		do_bop(event)
	pass
	
func do_bump(event: InputEvent):
	var horizontal_velocity = balloon_body.linear_velocity.x
	var difference = Max_Velocity_Horizontal-horizontal_velocity
	var scale_down = difference/Max_Velocity_Horizontal
	if scale_down > 1:
		scale_down = 1
	if not event.is_echo() and not event.is_released():
		print("Big Bump!")
		Beeper.bop_play()
		balloon_body.apply_central_impulse(Vector2i(Bump_Horizontal*scale_down,Bump_Vertical*-1))
		bump_debounce=Debounce_Rough_Msec*Debounce_Msec_Multiplier
	if event.is_echo() and bump_debounce == 0:
		print("Little Bump!")
		balloon_body.apply_central_impulse(Vector2i(Bump_Horizontal*scale_down,-1*Bump_Vertical*Hit_Ratio))
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
	if is_deflating:
		Current_Life-=1
		balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
	pass
	
var air: Resource = preload("res://Scenes/item_air_escape.tscn")
var airs: Array[ItemAirEscape]
var is_deflating: bool = false

func _on_rigid_body_balloon_body_entered(body: Node) -> void:
	var state: PhysicsDirectBodyState2D = balloon_body.get_last_known_physics_state()
	var active_collisions: int = state.get_contact_count()
	print("Body entered, active collisions: "+str(active_collisions))
	Beeper.bump_play()
	for i in range(active_collisions):
		var local_collision_point = balloon_body.to_local(state.get_contact_local_position(i))
		print("collided at: "+str(local_collision_point))
		if airs.size() > i:
			airs[i].position = local_collision_point
			airs[i].emitter.emitting = true
		else:
			var new_air: ItemAirEscape = air.instantiate()
			new_air.global_position = local_collision_point
			airs.append(new_air)
			balloon_body.add_child(new_air)
		if airs.size() > active_collisions:
			airs.resize(active_collisions)
		if active_collisions > 0:
			if not is_deflating:
				Current_Life-=5
				balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
			is_deflating = true
			Beeper.hiss_start()
		else:
			is_deflating = false
			Beeper.hiss_stop()
	pass

func request_life():
	balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
	pass

func _on_rigid_body_balloon_body_exited(body: Node) -> void:
	print("body exited")
	for item: ItemAirEscape in airs:
		item.emitter.emitting = false
	is_deflating = false
	Beeper.hiss_stop()
	pass
