extends Node2D

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")
var fighter_scene = preload("res://fighter.tscn")
var ufo_scene = preload("res://ufo.tscn")

var invader_list := []
var explode_list := []
var ufo :UFO
var fighter :Fighter

func get_gridsize(vp_size :Vector2) -> Vector2:
	return Vector2(vp_size.x / 13, vp_size.y / 12)

func _ready() -> void:
	var vp_size = get_viewport_rect().size
	var gridsize = get_gridsize(vp_size)

	var mv_vt = Vector2(20,20)
	for i in 11:
		var o = invader_scene.instantiate().init(Invader.Type.Invader3,mv_vt)
		add_child(o)
		invader_list.append(o)
		o.position = Vector2( (i+1) * gridsize.x, gridsize.y * 2)

	for j in 2:
		for i in 11:
			var o = invader_scene.instantiate().init(Invader.Type.Invader2,mv_vt)
			add_child(o)
			invader_list.append(o)
			o.position = Vector2( (i+1) * gridsize.x, gridsize.y * (j+3) )

	for j in 2:
		for i in 11:
			var o = invader_scene.instantiate().init(Invader.Type.Invader1,mv_vt)
			add_child(o)
			invader_list.append(o)
			o.position = Vector2( (i+1) * gridsize.x, gridsize.y * (j+5) )

	new_UFO()

	fighter = fighter_scene.instantiate()
	add_child(fighter)
	fighter.position = Vector2( (5) * gridsize.x, gridsize.y * (10) )

	var o = explode_scene.instantiate().init(Explode.Type.Invader)
	o.position = Vector2( randf_range(0,vp_size.x), randf_range(0,vp_size.y) )
	explode_list.append(o)
	add_child(o)

	o = explode_scene.instantiate().init(Explode.Type.UFO)
	o.position = Vector2( (5) * gridsize.x, gridsize.y  )
	explode_list.append(o)
	add_child(o)

	o = explode_scene.instantiate().init(Explode.Type.Fighter)
	o.position = Vector2( (7) * gridsize.x, gridsize.y * (10) )
	explode_list.append(o)
	add_child(o)

func _process(delta: float) -> void:
	move_UFO()
	move_bullets()
	move_invaders()
	move_fighter()

var inv_num := 0
var inv_move_dir := Invader.MoveDir.Right
func move_invaders() -> void:
	var o = invader_list[inv_num]
	o.position += o.get_move_vector(inv_move_dir)
	o.next_frame()
	if randi_range(0, 100) == 0:
		new_bullet(o.get_bullet_type(), o.position ).set_color(o.get_color())
	inv_num += 1
	if inv_num >= invader_list.size():
		inv_num = 0
		# change move vector
		inv_move_dir = Invader.get_dir_clockwise(inv_move_dir)

func new_bullet(t :Bullet.Type, p :Vector2) -> Bullet:
	var o = bullet_scene.instantiate().init(t)
	$Bullets.add_child(o)
	o.position = p
	return o

func add_fighter_bullet() -> void:
	new_bullet(Bullet.Type.Fighter, fighter.position ).set_color(fighter.get_color())

func move_bullets() -> void:
	for o in $Bullets.get_children():
		o.position += o.get_move_vector()
		if not get_viewport_rect().has_point(o.position):
			$Bullets.remove_child(o)

func new_UFO() -> void:
	if ufo != null:
		return
	var vp_size = get_viewport_rect().size
	var gridsize = get_gridsize(vp_size)
	ufo = ufo_scene.instantiate()
	add_child(ufo)
	var mv_speed = [3,10].pick_random()
	if randi_range(0, 1) == 0:
		ufo.set_move_vector(Vector2(mv_speed,0))
		ufo.position = Vector2( 0, gridsize.y)
	else :
		ufo.set_move_vector(Vector2(-mv_speed,0))
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
	ufo.position += ufo.get_move_vector()
	if not get_viewport_rect().has_point(ufo.position):
		del_UFO()
	elif randi_range(0, 100) == 0:
		new_bullet(Bullet.Type.UFO, ufo.position ).set_color(ufo.get_color())

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER:
			pass
		elif event.keycode == KEY_SPACE:
			add_fighter_bullet()
		elif event.keycode == KEY_LEFT:
			fighter_mv_vt = Vector2(-6,0)
		elif event.keycode == KEY_RIGHT:
			fighter_mv_vt = Vector2(6,0)
	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_LEFT:
			fighter_mv_vt = Vector2(0,0)
		elif event.keycode == KEY_RIGHT:
			fighter_mv_vt = Vector2(0,0)

var fighter_mv_vt :Vector2
func move_fighter() -> void:
	fighter.position += fighter_mv_vt
	if not get_viewport_rect().has_point(fighter.position):
		fighter.position = fighter.position.clamp(Vector2.ZERO, get_viewport_rect().size)
