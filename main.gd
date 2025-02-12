extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")
var fighter_scene = preload("res://fighter.tscn")
var ufo_scene = preload("res://ufo.tscn")

var vp_size :Vector2
var obj_list := []

func _ready() -> void:
	vp_size = get_viewport_rect().size

	add_obj(invader_scene.instantiate().set_type(Invader.Type.Invader1) )
	add_obj(invader_scene.instantiate().set_type(Invader.Type.Invader2) )
	add_obj(invader_scene.instantiate().set_type(Invader.Type.Invader3) )

	add_obj(fighter_scene.instantiate())
	add_obj(ufo_scene.instantiate())

	add_obj(bullet_scene.instantiate().set_type(Bullet.Type.Invader1) )
	add_obj(bullet_scene.instantiate().set_type(Bullet.Type.Invader2) )
	add_obj(bullet_scene.instantiate().set_type(Bullet.Type.Invader3) )
	add_obj(bullet_scene.instantiate().set_type(Bullet.Type.UFO) )
	add_obj(bullet_scene.instantiate().set_type(Bullet.Type.Fighter) )

	add_obj(explode_scene.instantiate().set_type(Explode.Type.Invader) )
	add_obj(explode_scene.instantiate().set_type(Explode.Type.UFO) )
	add_obj(explode_scene.instantiate().set_type(Explode.Type.Fighter) )

func add_obj(o ) -> void:
	add_child(o)
	o.position = Vector2( randf_range(0,vp_size.x), randf_range(0,vp_size.y))
	obj_list.append(o)

func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	for o in obj_list:
		o.next_frame()
