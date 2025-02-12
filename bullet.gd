extends Node2D
class_name Bullet

enum Type {Invader1,Invader2,Invader3,UFO,Fighter}

var bullet_type : Type

func set_type(t : Type) -> Bullet:
	bullet_type = t
	match bullet_type:
		Type.Invader1:
			$Sprite2D.texture = preload("res://assets/invader1_bullet.png")
		Type.Invader2:
			$Sprite2D.texture = preload("res://assets/invader2_bullet.png")
		Type.Invader3:
			$Sprite2D.texture = preload("res://assets/invader3_bullet.png")
		Type.UFO:
			$Sprite2D.texture = preload("res://assets/ufo_bullet.png")
		Type.Fighter:
			$Sprite2D.texture = preload("res://assets/fighter_bullet.png")
		_ :
			print_debug("invalid bullet type ", bullet_type)
	return self

func get_type() -> Type:
	return bullet_type

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h
