extends Area2D
class_name Bullet

signal ended(o :Bullet)

enum Type {Invader1,Invader2,Invader3,UFO,Fighter}
var move_vt = [
	Vector2(0,5),
	Vector2(0,6),
	Vector2(0,7),
	Vector2(0,8),
	Vector2(0,-8),
]
var bullet_type : Type

func init(t : Type) -> Bullet:
	bullet_type = t
	match bullet_type:
		Type.Invader1:
			collision_layer |= 1<<4
			collision_mask |= (1<<1) | (1<<3)
			$Sprite2D.texture = preload("res://assets/invader1_bullet.png")
		Type.Invader2:
			collision_layer |= 1<<4
			collision_mask |= (1<<1) | (1<<3)
			$Sprite2D.texture = preload("res://assets/invader2_bullet.png")
		Type.Invader3:
			collision_layer |= 1<<4
			collision_mask |= (1<<1) | (1<<3)
			$Sprite2D.texture = preload("res://assets/invader3_bullet.png")
		Type.UFO:
			collision_layer |= 1<<4
			collision_mask |= (1<<1) | (1<<3)
			$Sprite2D.texture = preload("res://assets/ufo_bullet.png")
		Type.Fighter:
			collision_layer |= 1<<3
			collision_mask |= (1) | (1<<2) | (1<<4)
			$Sprite2D.texture = preload("res://assets/fighter_bullet.png")
		_ :
			print_debug("invalid bullet type ", bullet_type)
	$CollisionShape2D.shape.size = $Sprite2D.texture.get_size() * $Sprite2D.scale
	return self

func get_type() -> Type:
	return bullet_type

func set_color(co :Color) -> void:
	$Sprite2D.self_modulate = co

func get_color() -> Color:
	return $Sprite2D.self_modulate

func next_frame() -> void:
	$Sprite2D.flip_h = not $Sprite2D.flip_h

func get_move_vector() -> Vector2:
	return move_vt[bullet_type]

func _on_timer_timeout() -> void:
	next_frame()

func _on_area_entered(_area: Area2D) -> void:
	ended.emit(self)
