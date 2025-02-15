extends Area2D
class_name Fighter

signal ended(o :Fighter)

func init() -> void:
	$CollisionShape2D.shape.size = $Sprite2D.texture.get_size() * $Sprite2D.scale

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func get_color() -> Color:
	return $Sprite2D.self_modulate

func next_frame() -> void:
	pass

func _on_timer_timeout() -> void:
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_area_entered(_area: Area2D) -> void:
	ended.emit(self)
