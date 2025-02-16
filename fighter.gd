extends Area2D
class_name Fighter

signal ended(o :Fighter)

#const BulletCountLimit = 2
#const BulletNextFireSec = 0.3

# for demo mode
const BulletCountLimit = 10
const BulletNextFireSec = 0.1

var valid :bool
func init() -> Fighter:
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

func _on_timer_timeout() -> void:
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_area_entered(_area: Area2D) -> void:
	ended.emit(self)
