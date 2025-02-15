extends Area2D
class_name UFO

signal ended(o :UFO)

func init() -> UFO:
	$CollisionShape2D.shape.size = $Sprite2D.texture.get_size() * $Sprite2D.scale
	return self

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func get_color() -> Color:
	return $Sprite2D.self_modulate

func next_frame() -> void:
	pass

var move_vector :Vector2
func set_move_vector( vt :Vector2 ) -> void:
	move_vector = vt

func get_move_vector() -> Vector2:
	return move_vector

func _on_timer_timeout() -> void:
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_area_entered(area: Area2D) -> void:
	ended.emit(self)
