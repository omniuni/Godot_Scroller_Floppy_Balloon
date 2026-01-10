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
var balloon: Polygon2D = $RigidBodyBalloon/BalloonPolygon
@onready
var balloon_animation: AnimationPlayer = $RigidBodyBalloon/BalloonAnimationPlayer
@onready
var balloon_collision: CollisionShape2D = $RigidBodyBalloon/BalloonCollisionShape

func _ready() -> void:
	balloon.self_modulate = GameSettings.Color_P1.lightened(0.2)
	generator.seed = GameSettings.Seed
	balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
	pass
	
func _physics_process(delta: float) -> void:
	var orientation = balloon_body.rotation
	var compensation = ( (orientation/.0007)*-1 )*delta
	balloon_body.apply_torque(compensation)
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
		balloon_body.apply_central_impulse(Vector2(Bump_Horizontal*scale_down,-1*Bump_Vertical*Hit_Ratio))
		bump_debounce=Debounce_Rough_Msec*generator.randi_range(1,Debounce_Msec_Multiplier)
	pass

# Placeholder for "bop" event
func do_bop(_event: InputEvent):
	pass
	
func freeze(frozen: bool) -> void:
	balloon_body.freeze = frozen
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
		if Current_Life <= 0:
			Current_Life = 0
			return
		Current_Life-=1
		var percent_life = snapped(Current_Life/Max_Life, 0.01)
		balloon_life.emit(percent_life*100)
		var seek_to_sec = 2-(2*percent_life)
		var scale_to = (percent_life*.8)+.2
		print("Seek to: "+str(seek_to_sec))
		if not balloon_animation.is_playing():
			balloon_animation.play("Deflate")
		balloon_animation.seek(seek_to_sec, true)
		balloon_animation.pause()
		balloon_collision.scale = Vector2(scale_to, scale_to)
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
		
		var tile_type = ""
		var tile_map_layer: TileMapLayer = null
		var tile_coords: Vector2i = Vector2i.ZERO
		var tile = null
		
		if body is TileMapLayer:
			tile_map_layer = body
			var tile_map_local: Vector2 = tile_map_layer.to_local(state.get_contact_local_position(i))
			tile_coords = tile_map_layer.local_to_map(tile_map_local)
			tile = tile_map_layer.get_cell_tile_data(tile_coords)
			tile_type = tile.get_custom_data("type")
			print_debug("Tile type: "+tile_type)
		
		if airs.size() > i:
			airs[i].position = local_collision_point
			if Current_Life > 0 and tile_type.is_empty():
				airs[i].emitter.emitting = true
			else:
				airs[i].emitter.emitting = false
		else:
			var new_air: ItemAirEscape = air.instantiate()
			new_air.global_position = local_collision_point
			airs.append(new_air)
			balloon_body.add_child(new_air)
		if airs.size() > active_collisions:
			airs.resize(active_collisions)
		if active_collisions > 0:
			if not is_deflating and Current_Life > 0:
				match tile_type:
					"safe":
						break
					"heal":
						Current_Life+=10
						var tile_type_ground: Vector2i = Vector2i(1, 0)
						tile_map_layer.set_cell(tile_coords, 0, tile_type_ground)
					_:
						Current_Life-=5
						is_deflating = true
						Beeper.hiss_start()
				balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
		else:
			is_deflating = false
			Beeper.hiss_stop()
	pass

func request_life():
	balloon_life.emit(snapped(Current_Life/Max_Life, 0.01)*100)
	pass

func _on_rigid_body_balloon_body_exited(_body: Node) -> void:
	print("body exited")
	for item: ItemAirEscape in airs:
		item.emitter.emitting = false
	is_deflating = false
	Beeper.hiss_stop()
	pass
