class_name TileMapLayerLimits
extends TileMapLayer

func _get_top_left(camera: Camera2D) -> Vector2:
	return camera.get_screen_center_position() - camera.get_viewport_rect().size / 2
	
func _get_bottom_right(camera: Camera2D) -> Vector2:
	return camera.get_screen_center_position() + camera.get_viewport_rect().size / 2

func get_cell_leftmost(camera: Camera2D) -> int:
	return local_to_map(to_local(_get_top_left(camera))).x
	
func get_cell_rightmost(camera: Camera2D) -> int:
	return local_to_map(to_local(_get_bottom_right(camera))).x
	
func get_cell_topmost(camera: Camera2D) -> int:
	return local_to_map(to_local(_get_top_left(camera))).y
	
func get_cell_bottommost(camera: Camera2D) -> int:
	return local_to_map(to_local(_get_bottom_right(camera))).y
