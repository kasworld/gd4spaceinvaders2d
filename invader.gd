extends Node2D
class_name Invader

enum InvaderType {Invader1,Invader2,Invader3}

var invader_type : InvaderType

func set_type(t : InvaderType) -> Invader:
	invader_type = t
	match invader_type:
		InvaderType.Invader1:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_1_sprite_frame.tres")
		InvaderType.Invader2:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_2_sprite_frame.tres")
		InvaderType.Invader3:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_3_sprite_frame.tres")
		_ :
			print_debug("invalid invader type ", invader_type)
	return self

func next_frame() -> void:
	$AnimatedSprite2D.frame = ($AnimatedSprite2D.frame +1) % $AnimatedSprite2D.sprite_frames.get_frame_count("default")
