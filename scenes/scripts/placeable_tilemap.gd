extends TileMap

class_name PlaceableTileMap

func get_tile_coords(vec: Vector2) -> Vector2:
	return Vector2(floor(vec.x / self.cell_size.x), floor(vec.y / self.cell_size.y))

func get_world_coords(vec: Vector2) -> Vector2:
	return Vector2(vec.x * self.cell_size.x, vec.y * self.cell_size.y)

func align_to_grid(object) -> void:
	place_at_tilev(get_tile_coords(object.position), object)
	
func place_at_tile(x: int, y: int, object: Node2D) -> void:
	object.position = get_world_coords(Vector2(x, y)) + (self.cell_size / 2)
	
func place_at_tilev(vec: Vector2, object: Node2D) -> void:
	object.position = get_world_coords(vec) + (self.cell_size / 2)