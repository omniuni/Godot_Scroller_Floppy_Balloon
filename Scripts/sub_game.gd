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
			else:
				centerpoint+=generator.randi_range(-1, 1)
			if(centerpoint-width_half-1 < tile_row_ceiling): centerpoint = tile_row_ceiling+width_half+1
			if(centerpoint+width_half+1 > tile_row_floor): centerpoint = tile_row_floor-width_half-1
			
			var ceiling_tile = Vector2i(i, tile_row_ceiling)
			var floor_tile = Vector2i(i, tile_row_floor)
			var tile = Vector2i(0,0)
			tile_map_cave_walls.set_cell(ceiling_tile, 0, tile)
			tile_map_cave_walls.set_cell(floor_tile, 0, tile)
			for j in range(tile_row_ceiling+1, tile_row_floor):
				var tile_target = Vector2i(i, j)
				var back_tile = Vector2i(3, 0)
				var fore_tile = Vector2i(1, 0)
				if(j > centerpoint-width_half and j < centerpoint+width_half):
					tile_map_cave_walls.set_cell(tile_target, 0, back_tile)
				else:
					tile_map_cave_walls.set_cell(tile_target, 0, fore_tile)
					
			cols_rendered.append(i)
	
	pass
