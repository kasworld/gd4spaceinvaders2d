extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")
var fighter_scene = preload("res://fighter.tscn")
var ufo_scene = preload("res://ufo.tscn")

var vp_size :Vector2
var obj_list := []
var invader_list := []

func _ready() -> void:
	vp_size = get_viewport_rect().size

	var inv_w = vp_size.x / 13
	var inv_h = vp_size.y / 12
	for i in 11:
		var o = invader_scene.instantiate().set_type(Invader.Type.Invader3)
		add_child(o)
		invader_list.append(o)
		o.position = Vector2( (i+1) * inv_w, inv_h * 2)

	for i in 11:
		for j in 2:
			var o = invader_scene.instantiate().set_type(Invader.Type.Invader2)
			add_child(o)
			invader_list.append(o)
			o.position = Vector2( (i+1) * inv_w, inv_h * (j+3) )

	for i in 11:
		for j in 2:
			var o = invader_scene.instantiate().set_type(Invader.Type.Invader1)
			add_child(o)
			invader_list.append(o)
			o.position = Vector2( (i+1) * inv_w, inv_h * (j+5) )

	var o = ufo_scene.instantiate()
	add_child(o)
	obj_list.append(o)
	o.position = Vector2( (4) * inv_w, inv_h * (1) )

	o = fighter_scene.instantiate()
	add_child(o)
	obj_list.append(o)
	o.position = Vector2( (5) * inv_w, inv_h * (10) )



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
		o.set_color(NamedColorList.color_list.pick_random()[0])

	for o in invader_list:
		o.next_frame()
		o.set_color(NamedColorList.color_list.pick_random()[0])
