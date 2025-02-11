extends Node2D
class_name Invader1Bullet

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h
