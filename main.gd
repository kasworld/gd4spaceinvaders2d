extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var invader_explod_scene = preload("res://invader_explode.tscn")

var fighter_scene = preload("res://fighter.tscn")
var fighter_explode_scene = preload("res://fighter_explode.tscn")

var ufo_scene = preload("res://ufo.tscn")
var ufo_explode_scene = preload("res://ufo_explode.tscn")


var inv1 : Invader
var bul1 : Bullet
var vp_size :Vector2
func _ready() -> void:
	vp_size = get_viewport_rect().size

	inv1 = invader_scene.instantiate().set_type(Invader.Type.Invader1)
	add_child(inv1)
	inv1.position = vp_size *0.3

	bul1 = bullet_scene.instantiate().set_type(Bullet.Type.Invader1)
	add_child(bul1)
	bul1.position = vp_size * 0.6

func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	inv1.next_frame()
	bul1.next_frame()
