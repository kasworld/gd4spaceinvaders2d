extends Area2D
class_name Invader

signal ended(o :Invader)

enum Type {Invader1,Invader2,Invader3}

static var move_vector := [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO]
static func set_move_vector(mv_vt :Vector2) -> void:
	move_vector[Settings.MoveDir.Right] = Vector2(mv_vt.x,0)
	move_vector[Settings.MoveDir.Left] = Vector2(-mv_vt.x,0)
	move_vector[Settings.MoveDir.Up] = Vector2(0,-mv_vt.y)
	move_vector[Settings.MoveDir.Down] = Vector2(0,mv_vt.y)

static func get_move_vector(dir :Settings.MoveDir) -> Vector2:
	return move_vector[dir]

var valid :bool
var invader_type : Type
func init(t : Type) -> Invader:
	invader_type = t
	valid = true
	match invader_type:
		Type.Invader1:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_1_sprite_frame.tres")
		Type.Invader2:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_2_sprite_frame.tres")
		Type.Invader3:
			$AnimatedSprite2D.sprite_frames = preload("res://invader_3_sprite_frame.tres")
		_ :
			print_debug("invalid invader type ", invader_type)
	$CollisionShape2D.shape.size = $AnimatedSprite2D.sprite_frames.get_frame_texture("default",0).get_size() * $AnimatedSprite2D.scale
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
	return 0 as Bullet.Type

func set_color(co :Color) -> void:
	$AnimatedSprite2D.self_modulate = co

func get_color() -> Color:
	return $AnimatedSprite2D.self_modulate

func get_score() -> int:
	return Settings.InvaderScore[invader_type]


func next_frame() -> void:
	$AnimatedSprite2D.frame = ($AnimatedSprite2D.frame +1) % $AnimatedSprite2D.sprite_frames.get_frame_count("default")
	set_color(NamedColorList.color_list.pick_random()[0])

func _on_timer_timeout() -> void:
	next_frame()

func _on_area_entered(_area: Area2D) -> void:
	if valid:
		hide()
		set_process_mode.call_deferred(PROCESS_MODE_DISABLED)
		valid = false
		ended.emit(self)
