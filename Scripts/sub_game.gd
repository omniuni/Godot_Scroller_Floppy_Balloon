extends SubViewportContainer

@onready
var tile_map_cave_walls: TileMapLayerLimits = $SubViewport/TileMapGroup/CaveWalls

@onready
var timerTerrain: Timer = $TimerGenerateTerrain

@onready
var game_camera: Camera2D = $SubViewport.get_camera_2d()

var generator = RandomNumberGenerator.new()

func _ready() -> void:
	generator.seed = GameSettings.Seed
	floor_and_ceiling()
	timerTerrain.start()
	pass

func _process(delta: float) -> void:
	
	pass

func _on_timer_timeout() -> void:
	floor_and_ceiling()
	pass
	
var cols_rendered = Array()

var centerpoint = -1
var width_half = 5
	
@export var tile_type_rock: Vector2i = Vector2i(0,0)
@export var tile_type_ground: Vector2i = Vector2i(1, 0)
@export var tile_type_cave: Vector2i = Vector2i(3, 0)
@export var tile_type_cave_crack: Vector2i = Vector2i(3, 1)
@export var tile_type_cave_rock: Vector2i = Vector2i(4, 1)
@export var tile_type_safe: Vector2i = Vector2i(4, 0)
@export var tile_type_heal: Vector2i = Vector2i(5, 0)
@export var tile_type_sg_sm: Vector2i = Vector2i(6, 0)
@export var tile_type_sc_sm: Vector2i = Vector2i(7, 0)
@export var tile_type_sg_lgb: Vector2i = Vector2i(8, 1)
@export var tile_type_sg_lgt: Vector2i = Vector2i(8, 0)
@export var platform_start: int = 4
	
func floor_and_ceiling():
	
	var tile_row_ceiling = 0
	var tile_row_floor = 17
	var buffer = 6
	
	var gen_start = tile_map_cave_walls.get_cell_leftmost(game_camera)-buffer
	var gen_end = tile_map_cave_walls.get_cell_rightmost(game_camera)+buffer
	
	for i in range(gen_start, gen_end):
		if(not cols_rendered.has(i)):
		
			print("Rendering new Column: "+str(i))
			
			if(centerpoint == -1):
				centerpoint = generator.randi_range(tile_row_ceiling, tile_row_floor)
			elif i > platform_start:
				centerpoint+=generator.randi_range(-1, 1)
			if(centerpoint-width_half-1 < tile_row_ceiling): centerpoint = tile_row_ceiling+width_half+1
			if(centerpoint+width_half+1 > tile_row_floor): centerpoint = tile_row_floor-width_half-1
			
			var ceiling_tile = Vector2i(i, tile_row_ceiling)
			var floor_tile = Vector2i(i, tile_row_floor)
			tile_map_cave_walls.set_cell(ceiling_tile, 0, tile_type_rock)
			tile_map_cave_walls.set_cell(floor_tile, 0, tile_type_rock)
			for j in range(tile_row_ceiling+1, tile_row_floor):
				var tile_target = Vector2i(i, j)
				if(j > centerpoint-width_half and j < centerpoint+width_half):
					var rock_chance = generator.randi_range(0, 70)
					if rock_chance < 2:
						tile_map_cave_walls.set_cell(tile_target, 0, tile_type_cave_crack)
					elif rock_chance < 4:
						tile_map_cave_walls.set_cell(tile_target, 0, tile_type_cave_rock)
					else:
						tile_map_cave_walls.set_cell(tile_target, 0, tile_type_cave)
				else:
					tile_map_cave_walls.set_cell(tile_target, 0, tile_type_ground)
					
			cols_rendered.append(i)
			
			# Read some of the previous tiles.
			# This will be used to update the map with features.
			var tile_baseline = centerpoint+width_half
			var coords_floor = Vector2i(i, tile_baseline)
			var coords_floor_prev_1 = Vector2i(i-1, tile_baseline)
			var coords_floor_prev_2 = Vector2i(i-2, tile_baseline)
			var atlas_prev_1 = tile_map_cave_walls.get_cell_atlas_coords(coords_floor_prev_1)
			var atlas_prev_2 = tile_map_cave_walls.get_cell_atlas_coords(coords_floor_prev_2)
			var coords_up_prev_1 = Vector2i(i-1, tile_baseline-1)
			var coords_up_prev_2 = Vector2i(i-2, tile_baseline-1)
			var coords_up_up_prev_1 = Vector2i(i-1, tile_baseline-2)
			var atlas_up_prev_1 = tile_map_cave_walls.get_cell_atlas_coords(coords_up_prev_1)
			var atlas_up_prev_2 = tile_map_cave_walls.get_cell_atlas_coords(coords_up_prev_2)
			var tile_ceiling = centerpoint-width_half
			var coords_ceiling_dn_prev_1 = Vector2i(i-1, tile_ceiling+1)
			var coords_ceiling_dn_prev_2 = Vector2i(i-2, tile_ceiling+1)
			var atlas_ceiling_dn_prev_1 = tile_map_cave_walls.get_cell_atlas_coords(coords_ceiling_dn_prev_1)
			var atlas_ceiling_dn_prev_2 = tile_map_cave_walls.get_cell_atlas_coords(coords_ceiling_dn_prev_2)
				
			if i > 1:
				# Search back to see if this is a platform
				var prev_ground = atlas_prev_1 == tile_type_ground and atlas_prev_2 == tile_type_ground
				var prev_safe = atlas_prev_1 == tile_type_safe and atlas_prev_2 == tile_type_safe
				var prev_heal = atlas_prev_1 == tile_type_heal and atlas_prev_2 == tile_type_heal
				if prev_ground or prev_safe or prev_heal:
					if atlas_up_prev_1 == tile_type_cave and atlas_up_prev_2 == tile_type_cave:
						if prev_ground:
							print('prev_ground')       
							var tile_type_new: Vector2i
							if generator.randi_range(0, 10) < 3:
								tile_type_new = tile_type_heal
							else:
								tile_type_new = tile_type_safe
							tile_map_cave_walls.set_cell(coords_floor, 0, tile_type_new)
							tile_map_cave_walls.set_cell(coords_floor_prev_1, 0, tile_type_new)
							tile_map_cave_walls.set_cell(coords_floor_prev_2, 0, tile_type_new)
						if prev_safe:
							tile_map_cave_walls.set_cell(coords_floor, 0, tile_type_safe)
							tile_map_cave_walls.set_cell(coords_floor_prev_1, 0, tile_type_safe)
							tile_map_cave_walls.set_cell(coords_floor_prev_2, 0, tile_type_safe)
						if prev_heal:
							tile_map_cave_walls.set_cell(coords_floor, 0, tile_type_heal)
							tile_map_cave_walls.set_cell(coords_floor_prev_1, 0, tile_type_heal)
							tile_map_cave_walls.set_cell(coords_floor_prev_2, 0, tile_type_heal)
			
			if i > 2:
				#search back to see if we have a stalagmite
				if atlas_up_prev_1 == tile_type_ground and atlas_up_prev_2 == tile_type_cave:
					if generator.randi_range(0, 10) < 3:
						tile_map_cave_walls.set_cell(coords_up_prev_1, 0, tile_type_sg_lgb)
						tile_map_cave_walls.set_cell(coords_up_up_prev_1, 0, tile_type_sg_lgt )
					else:
						tile_map_cave_walls.set_cell(coords_up_prev_1, 0, tile_type_sg_sm)
				if atlas_ceiling_dn_prev_1 == tile_type_ground and atlas_ceiling_dn_prev_2 == tile_type_cave:
					tile_map_cave_walls.set_cell(coords_ceiling_dn_prev_1, 0, tile_type_sc_sm)
				
	
	pass
