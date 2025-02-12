extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")
var fighter_scene = preload("res://fighter.tscn")
var ufo_scene = preload("res://ufo.tscn")

var invader_list := []
var bullet_list := []
var explode_list := []
var ufo :UFO
var fighter :Fighter

func get_gridsize(vp_size :Vector2) -> Vector2:
	return Vector2(vp_size.x / 13, vp_size.y / 12)

func _ready() -> void:
	var vp_size = get_viewport_rect().size
	var gridsize = get_gridsize(vp_size)

	for i in 11:
		var o = invader_scene.instantiate().set_type(Invader.Type.Invader3)
		add_child(o)
		invader_list.append(o)
		o.position = Vector2( (i+1) * gridsize.x, gridsize.y * 2)

	for i in 11:
		for j in 2:
			var o = invader_scene.instantiate().set_type(Invader.Type.Invader2)
			add_child(o)
			invader_list.append(o)
			o.position = Vector2( (i+1) * gridsize.x, gridsize.y * (j+3) )

	for i in 11:
		for j in 2:
			var o = invader_scene.instantiate().set_type(Invader.Type.Invader1)
			add_child(o)
			invader_list.append(o)
			o.position = Vector2( (i+1) * gridsize.x, gridsize.y * (j+5) )

	new_UFO()

	fighter = fighter_scene.instantiate()
	add_child(fighter)
	fighter.position = Vector2( (5) * gridsize.x, gridsize.y * (10) )

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
	move_UFO()

	change_frame_color(invader_list[inv_num])
	inv_num += 1
	inv_num %= invader_list.size()

func new_UFO() -> void:
	if ufo != null:
		return
	var vp_size = get_viewport_rect().size
	var gridsize = get_gridsize(vp_size)
	ufo = ufo_scene.instantiate()
	add_child(ufo)
	if randi_range(0, 1) == 0:
		ufo.set_move_vector(Vector2(3,0))
		ufo.position = Vector2( 0, gridsize.y)
	else :
		ufo.set_move_vector(Vector2(-3,0))
		ufo.position = Vector2( vp_size.x, gridsize.y)

func del_UFO() -> void:
	if ufo == null:
		return
	remove_child(ufo)
	ufo = null
	new_UFO.call_deferred()

func move_UFO() -> void:
	if ufo == null :
		return
	var vp_size = get_viewport_rect().size
	ufo.position += ufo.get_move_vector()
	if not get_viewport_rect().has_point(ufo.position):
		del_UFO()

func change_frame_color(o) -> void:
	if o == null:
		return
	o.next_frame()
	o.set_color(NamedColorList.color_list.pick_random()[0])

func _on_timer_timeout() -> void:
	change_frame_color(ufo)
	change_frame_color(fighter)


# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	var vp_size = get_viewport_rect().size
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
