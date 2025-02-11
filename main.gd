extends Node2D

var invader1_scene = preload("res://invader_1.tscn")
var invader1bullet_scene = preload("res://invader_1_bullet.tscn")
var invader2_scene = preload("res://invader_2.tscn")
var invader2bullet_scene = preload("res://invader_2_bullet.tscn")
var invader3_scene = preload("res://invader_3.tscn")
var invader3bullet_scene = preload("res://invader_3_bullet.tscn")
var invader_explode_scene = preload("res://invader_explode.tscn")

var fighter_scene = preload("res://fighter.tscn")
var fighter_bullet_scene = preload("res://fighter_bullet.tscn")
var fighter_explode_scene = preload("res://fighter_explode.tscn")

var ufo_scene = preload("res://ufo.tscn")
var ufo_bullet_scene = preload("res://ufo_bullet.tscn")
var ufo_explode_scene = preload("res://ufo_explode.tscn")


var inv1 : Invader1
var bul1 : Invader1Bullet
var vp_size :Vector2
func _ready() -> void:
	vp_size = get_viewport_rect().size

	inv1 = invader1_scene.instantiate()
	add_child(inv1)
	inv1.position = vp_size *0.3

	bul1 = invader1bullet_scene.instantiate()
	add_child(bul1)
	bul1.position = vp_size * 0.6

func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	inv1.next_frame()
	bul1.next_frame()
