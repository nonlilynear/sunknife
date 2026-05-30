extends Node2D

var base_width: int = 32
var base_height: int = 16

func set_size(width: int):
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = Vector2(base_width * width, base_height)
	$Sprite2D.region_rect = Rect2(54, 42, base_width * width, base_height)
