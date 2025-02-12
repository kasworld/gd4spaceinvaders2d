extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")
var fighter_scene = preload("res://fighter.tscn")
var ufo_scene = preload("res://ufo.tscn")

var vp_size :Vector2
var invader_list := []
var bullet_list := []
var explode_list := []
var ufo :UFO
var fighter :Fighter

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

	ufo = ufo_scene.instantiate()
	add_child(ufo)
	ufo.position = Vector2( (4) * inv_w, inv_h * (1) )

	fighter = fighter_scene.instantiate()
	add_child(fighter)
	fighter.position = Vector2( (5) * inv_w, inv_h * (10) )

	bullet_list.append(bullet_scene.instantiate().set_type(Bullet.Type.Invader1) )
	bullet_list.append(bullet_scene.instantiate().set_type(Bullet.Type.Invader2) )
	bullet_list.append(bullet_scene.instantiate().set_type(Bullet.Type.Invader3) )
	bullet_list.append(bullet_scene.instantiate().set_type(Bullet.Type.UFO) )
	bullet_list.append(bullet_scene.instantiate().set_type(Bullet.Type.Fighter) )
	for o in bullet_list:
		add_child(o)
		o.position = Vector2( randf_range(0,vp_size.x), randf_range(0,vp_size.y))


	explode_list.append(explode_scene.instantiate().set_type(Explode.Type.Invader) )
	explode_list.append(explode_scene.instantiate().set_type(Explode.Type.UFO) )
	explode_list.append(explode_scene.instantiate().set_type(Explode.Type.Fighter) )
	for o in explode_list:
		add_child(o)
		o.position = Vector2( randf_range(0,vp_size.x), randf_range(0,vp_size.y))

var inv_num := 0
func _process(delta: float) -> void:
	ufo.position.x += 3
	if ufo.position.x > vp_size.x:
		ufo.position.x = 0

	change_frame_color(invader_list[inv_num])
	inv_num += 1
	inv_num %= invader_list.size()

func change_frame_color(o) -> void:
	o.next_frame()
	o.set_color(NamedColorList.color_list.pick_random()[0])

func _on_timer_timeout() -> void:
	change_frame_color(ufo)
	change_frame_color(fighter)


# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER:
			pass
		elif event.keycode == KEY_SPACE:
			pass
		elif event.keycode == KEY_LEFT:
			fighter.position.x -= 8
			if fighter.position.x < 0:
				fighter.position.x = 0
		elif event.keycode == KEY_RIGHT:
			fighter.position.x += 8
			if fighter.position.x > vp_size.x:
				fighter.position.x = vp_size.x
