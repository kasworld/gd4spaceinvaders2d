extends Node2D
class_name InvaderBullet

var invader_type : Invader.Type

func set_type(t : Invader.Type) -> InvaderBullet:
	invader_type = t
	match invader_type:
		Invader.Type.Invader1:
			$Sprite2D.texture = preload("res://assets/invader1_bullet.png")
		Invader.Type.Invader2:
			$Sprite2D.texture = preload("res://assets/invader2_bullet.png")
		Invader.Type.Invader3:
			$Sprite2D.texture = preload("res://assets/invader3_bullet.png")
		_ :
			print_debug("invalid invader type ", invader_type)
	return self

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h
