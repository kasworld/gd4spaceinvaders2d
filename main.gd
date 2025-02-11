extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")

var fighter_scene = preload("res://fighter.tscn")

var ufo_scene = preload("res://ufo.tscn")


var inv1 : Invader
var bul1 : Bullet
var exp1 : Explode
var vp_size :Vector2
func _ready() -> void:
	vp_size = get_viewport_rect().size

	inv1 = invader_scene.instantiate().set_type(Invader.Type.Invader1)
	add_child(inv1)
	inv1.position = vp_size *0.3

	bul1 = bullet_scene.instantiate().set_type(Bullet.Type.Invader1)
	add_child(bul1)
	bul1.position = vp_size * 0.5

	exp1 = explode_scene.instantiate().set_type(Explode.Type.Invader)
	add_child(exp1)
	exp1.position = vp_size * 0.7


func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	inv1.next_frame()
	bul1.next_frame()
