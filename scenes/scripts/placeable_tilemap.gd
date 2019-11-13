extends TileMap

class_name PlaceableTileMap

func clear():
	var children: Array = self.get_children()
	
	.clear()

func get_tile_coords(vec: Vector2) -> Vector2:
	return Vector2(floor(vec.x / self.cell_size.x), floor(vec.y / self.cell_size.y))

func get_world_coords(vec: Vector2) -> Vector2:
	return Vector2(vec.x * self.cell_size.x, vec.y * self.cell_size.y)

func align_to_grid(object) -> void:
	place_at_tilev(get_tile_coords(object.position), object, false)
	
func place_at_tile(x: int, y: int, object: Node2D) -> void:
	object.position = get_world_coords(Vector2(x, y)) + (self.cell_size / 2)
	add_child(object)
	
func place_at_tilev(vec: Vector2, object: Node2D, with_obj=true) -> void:
	object.position = get_world_coords(vec) + (self.cell_size / 2)
	
	if with_obj:
		add_child(object)