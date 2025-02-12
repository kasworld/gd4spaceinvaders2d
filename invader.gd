extends Node2D
class_name Invader

enum Type {Invader1,Invader2,Invader3}

var invader_type : Type

func set_type(t : Type) -> Invader:
	invader_type = t
	match invader_type:
		Type.Invader1:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_1_sprite_frame.tres")
		Type.Invader2:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_2_sprite_frame.tres")
		Type.Invader3:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_3_sprite_frame.tres")
		_ :
			print_debug("invalid invader type ", invader_type)
	return self

func set_color(co :Color) -> void:
	$AnimatedSprite2D.self_modulate = co

func next_frame() -> void:
	$AnimatedSprite2D.frame = ($AnimatedSprite2D.frame +1) % $AnimatedSprite2D.sprite_frames.get_frame_count("default")
