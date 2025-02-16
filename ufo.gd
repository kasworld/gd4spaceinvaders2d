extends Area2D
class_name UFO

signal ended(o :UFO)

enum MoveDir {Left,Right}
enum MoveSpeed {Low,High}

const Speed = [3,10]

var speed :MoveSpeed
var move_dir :MoveDir
var move_vector :Vector2
var valid :bool
func init(dir :MoveDir, spd :MoveSpeed) -> UFO:
	speed = spd
	move_dir = dir
	if move_dir == MoveDir.Right:
		move_vector = Vector2(Speed[speed],0)
	else:
		move_vector = Vector2(-Speed[speed],0)
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

func get_score() -> int:
	return Settings.UFOScore[speed]

func get_move_vector() -> Vector2:
	return move_vector

func _on_timer_timeout() -> void:
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_area_entered(_area: Area2D) -> void:
	if valid:
		deinit()
		ended.emit(self)
