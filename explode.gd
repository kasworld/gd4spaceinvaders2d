extends Node2D
class_name Explode

enum Type {Invader,UFO,Fighter}

var explode_type : Type

func set_type(t : Type) -> Explode:
	explode_type = t
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

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h
