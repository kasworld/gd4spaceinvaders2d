extends Node2D
class_name Explode

signal ended(o :Explode)

enum Type {Invader,UFO,Fighter}

var explode_type : Type
var dur_sec :float
func init(t : Type, sec :float = 0.5) -> Explode:
	explode_type = t
	dur_sec = sec
	match explode_type:
		Type.Invader:
			$Sprite2D.texture = preload("res://assets/invader_explode.png")
		Type.UFO:
			$Sprite2D.texture = preload("res://assets/ufo_explode.png")
		Type.Fighter:
			$Sprite2D.texture = preload("res://assets/fighter_explode.png")
		_ :
			print_debug("invalid explode type ", explode_type)
	return self

func _ready() -> void:
	$Timer.start(dur_sec)

func get_type() -> Type:
	return explode_type

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func get_color() -> Color:
	return $Sprite2D.self_modulate

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h

func _process(delta: float) -> void:
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_timer_timeout() -> void:
	ended.emit(self)
