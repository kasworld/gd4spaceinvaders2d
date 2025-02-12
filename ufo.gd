extends Node2D
class_name UFO

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func next_frame() -> void:
	pass
