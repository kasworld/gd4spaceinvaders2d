extends Area2D
class_name UFO

signal ended(o :UFO)

var valid :bool
func init() -> UFO:
	var mv_speed = [3,10].pick_random()
	if randi_range(0, 1) == 0:
		set_move_vector(Vector2(mv_speed,0))
	else :
		set_move_vector(Vector2(-mv_speed,0))
	show()
	set_process_mode.call_deferred(PROCESS_MODE_INHERIT)
	valid = true
	return self

func deinit() -> void:
	hide()
	valid = false
	set_process_mode.call_deferred(PROCESS_MODE_DISABLED)

func _ready() -> void:
	$CollisionShape2D.shape.size = $Sprite2D.texture.get_size() * $Sprite2D.scale

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

func _on_area_entered(_area: Area2D) -> void:
	if valid:
		deinit()
		ended.emit(self)
