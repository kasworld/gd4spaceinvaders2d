extends Node2D

const InvaderCount_X = 11
const GridCount_X = 13
const GridCount_Y = 12

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")
var fighter_scene = preload("res://fighter.tscn")
var ufo_scene = preload("res://ufo.tscn")

var invader_list := []
var explode_list := []
var fighter :Fighter

var gamefield_size :Vector2
func get_gamefield_rect() -> Rect2:
	return Rect2(Vector2.ZERO, gamefield_size)
func get_gridsize() -> Vector2:
	return Vector2(gamefield_size.x / GridCount_X, gamefield_size.y / GridCount_Y)
func calc_grid_position(x :float, y :float) -> Vector2:
	var gridsize = get_gridsize()
	return Vector2(x*gridsize.x,y*gridsize.y)

func _ready() -> void:
	var vp_size = get_viewport_rect().size
	gamefield_size = Vector2(vp_size.x*0.7,vp_size.y)
	$GameField.position = Vector2(0,0)
	$GameField.size = gamefield_size
	var gridsize = get_gridsize()

	var mv_vt = Vector2(20,20)
	Invader.set_move_vector(mv_vt)

	for i in InvaderCount_X:
		var o = invader_scene.instantiate().init(Invader.Type.Invader3)
		$GameField.add_child(o)
		invader_list.append(o)
		o.position = calc_grid_position(i+1,2) #Vector2( (i+1) * gridsize.x, gridsize.y * 2)

	for j in 2:
		for i in InvaderCount_X:
			var o = invader_scene.instantiate().init(Invader.Type.Invader2)
			$GameField.add_child(o)
			invader_list.append(o)
			o.position = calc_grid_position(i+1,j+3) # Vector2( (i+1) * gridsize.x, gridsize.y * (j+3) )

	for j in 2:
		for i in InvaderCount_X:
			var o = invader_scene.instantiate().init(Invader.Type.Invader1)
			$GameField.add_child(o)
			invader_list.append(o)
			o.position = calc_grid_position(i+1,j+5) # Vector2( (i+1) * gridsize.x, gridsize.y * (j+5) )

	fighter = fighter_scene.instantiate()
	$GameField.add_child(fighter)
	fighter.position = calc_grid_position(5,GridCount_Y-1) # Vector2( (5) * gridsize.x, gridsize.y * (GridCount_Y-1) )

	var o = explode_scene.instantiate().init(Explode.Type.Invader)
	o.position = Vector2( randf_range(0,gamefield_size.x), randf_range(0,gamefield_size.y) )
	explode_list.append(o)
	$GameField.add_child(o)

	o = explode_scene.instantiate().init(Explode.Type.UFO)
	o.position = calc_grid_position(5,1) # Vector2( (5) * gridsize.x, gridsize.y  )
	explode_list.append(o)
	$GameField.add_child(o)

	o = explode_scene.instantiate().init(Explode.Type.Fighter)
	o.position = calc_grid_position(7,GridCount_Y-1) # Vector2( (7) * gridsize.x, gridsize.y * (GridCount_Y-1) )
	explode_list.append(o)
	$GameField.add_child(o)

func _process(delta: float) -> void:
	if $GameField/UFO.visible:
		move_UFO()
	elif randi_range(0, 100) == 0:
		new_UFO()
	move_bullets()
	move_invaders()
	move_fighter()

var inv_num := 0
var inv_move_dir := Invader.MoveDir.Right
func move_invaders() -> void:
	var o = invader_list[inv_num]
	o.position += Invader.get_move_vector(inv_move_dir)
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
	$GameField/Bullets.add_child(o)
	o.position = p
	return o

func add_fighter_bullet() -> void:
	new_bullet(Bullet.Type.Fighter, fighter.position ).set_color(fighter.get_color())

func move_bullets() -> void:
	for o in $GameField/Bullets.get_children():
		o.position += o.get_move_vector()
		if not get_gamefield_rect().has_point(o.position):
			$GameField/Bullets.remove_child(o)

func new_UFO() -> void:
	var gridsize = get_gridsize()
	var mv_speed = [3,10].pick_random()
	if randi_range(0, 1) == 0:
		$GameField/UFO.set_move_vector(Vector2(mv_speed,0))
		$GameField/UFO.position = calc_grid_position(0,1)
	else :
		$GameField/UFO.set_move_vector(Vector2(-mv_speed,0))
		$GameField/UFO.position = calc_grid_position( GridCount_X,1)
	$GameField/UFO.show()

func del_UFO() -> void:
	$GameField/UFO.hide()

func move_UFO() -> void:
	$GameField/UFO.position += $GameField/UFO.get_move_vector()
	if not get_gamefield_rect().has_point($GameField/UFO.position):
		del_UFO()
	elif randi_range(0, 100) == 0:
		new_bullet(Bullet.Type.UFO, $GameField/UFO.position ).set_color($GameField/UFO.get_color())

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
	if not get_gamefield_rect().has_point(fighter.position):
		fighter.position = fighter.position.clamp(Vector2.ZERO, gamefield_size)
