extends Node2D
class_name InvaderBullet

var invader_type : Invader.InvaderType

func set_type(t : Invader.InvaderType) -> InvaderBullet:
	invader_type = t
	match invader_type:
		Invader.InvaderType.Invader1:
			$Sprite2D.texture = preload("res://assets/invader1_bullet.png")
		Invader.InvaderType.Invader2:
			$Sprite2D.texture = preload("res://assets/invader2_bullet.png")
		Invader.InvaderType.Invader3:
			$Sprite2D.texture = preload("res://assets/invader3_bullet.png")
		_ :
			print_debug("invalid invader type ", invader_type)
	return self

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h
