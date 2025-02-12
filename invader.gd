extends Node2D
class_name Invader

enum Type {Invader1,Invader2,Invader3}

var invader_type : Type

func init(t : Type) -> Invader:
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

func get_type() -> Type:
	return invader_type

func get_bullet_type() -> Bullet.Type:
	match invader_type:
		Type.Invader1:
			return Bullet.Type.Invader1
		Type.Invader2:
			return Bullet.Type.Invader2
		Type.Invader3:
			return Bullet.Type.Invader3
	print_debug("something wrong ", invader_type)
	return 0

func set_color(co :Color) -> void:
	$AnimatedSprite2D.self_modulate = co

func get_color() -> Color:
	return $AnimatedSprite2D.self_modulate

func next_frame() -> void:
	$AnimatedSprite2D.frame = ($AnimatedSprite2D.frame +1) % $AnimatedSprite2D.sprite_frames.get_frame_count("default")
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_timer_timeout() -> void:
	next_frame()
