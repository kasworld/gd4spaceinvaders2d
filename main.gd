extends Node2D

const InvaderCount_X = 11
const GridCount_X = 13
const GridCount_Y = 12

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")

var gamefield_size :Vector2
func get_gamefield_rect() -> Rect2:
	return Rect2(Vector2.ZERO, gamefield_size)
func get_gridsize() -> Vector2:
	return Vector2(gamefield_size.x / GridCount_X, gamefield_size.y / GridCount_Y)
func calc_grid_position(x :float, y :float) -> Vector2:
	var gridsize = get_gridsize()
	return Vector2(x*gridsize.x,y*gridsize.y)
func calc_invader_move_area() -> Rect2:
	return Rect2( calc_grid_position(1,1), calc_grid_position(GridCount_X-2,GridCount_Y-3))
func invader_move_down_limit() -> float:
	return calc_invader_move_area().end.y


func _ready() -> void:
	var vp_size = get_viewport_rect().size
	gamefield_size = Vector2(vp_size.x*0.7,vp_size.y)
	$GameField.position = Vector2(0,0)
	$GameField.size = gamefield_size
	var gridsize = get_gridsize()
	$UI.position = Vector2(gamefield_size.x,0)
	$UI.size = Vector2(vp_size.x - gamefield_size.x, vp_size.y)

	$GameField/Fighter.position = calc_grid_position(5,GridCount_Y-1)

	init_invader()

var inv_num := 0
var inv_move_dir_order := 0
var need_change_dir :bool
func init_invader() -> void:
	for o in $GameField/Invaders.get_children():
		$GameField/Invaders.remove_child(o)
	inv_num = 0
	inv_move_dir_order = 0
	need_change_dir = false
	Invader.set_move_vector(Vector2(20,20))

	for i in InvaderCount_X:
		var o = invader_scene.instantiate().init(Invader.Type.Invader3)
		$GameField/Invaders.add_child(o)
		o.position = calc_grid_position(i+1,2)

	for j in 2:
		for i in InvaderCount_X:
			var o = invader_scene.instantiate().init(Invader.Type.Invader2)
			$GameField/Invaders.add_child(o)
			o.position = calc_grid_position(i+1,j+3)

	for j in 2:
		for i in InvaderCount_X:
			var o = invader_scene.instantiate().init(Invader.Type.Invader1)
			$GameField/Invaders.add_child(o)
			o.position = calc_grid_position(i+1,j+5)

func invader_explode(pos :Vector2) -> void:
	var o = explode_scene.instantiate().init(Explode.Type.Invader)
	o.position = pos
	$GameField/Explodes.add_child(o)
	o.ended.connect(end_explode)

func UFO_explode(pos :Vector2) -> void:
	var o = explode_scene.instantiate().init(Explode.Type.UFO)
	o.position = pos
	$GameField/Explodes.add_child(o)
	o.ended.connect(end_explode)

func fighter_explode(pos :Vector2) -> void:
	var o = explode_scene.instantiate().init(Explode.Type.Fighter)
	o.position = pos
	$GameField/Explodes.add_child(o)
	o.ended.connect(end_explode)

func end_explode(o :Explode) ->void:
	$GameField/Explodes.remove_child(o)

func _process(delta: float) -> void:
	if $GameField/UFO.visible:
		move_UFO()
	elif randi_range(0, 100) == 0:
		new_UFO()
	move_bullets()
	move_invaders()
	move_fighter()

func move_invaders() -> void:
	var o = $GameField/Invaders.get_child(inv_num)
	var move_dir = Invader.move_dir_order[inv_move_dir_order]
	o.position += Invader.get_move_vector( move_dir )
	o.next_frame()
	if randi_range(0, 100) == 0:
		new_bullet(o.get_bullet_type(), o.position ).set_color(o.get_color())
	if randi_range(0, 100) == 0:
		invader_explode(o.position)
	if not calc_invader_move_area().has_point(o.position):
		need_change_dir = true
		if o.position.y > invader_move_down_limit():
			# game over
			init_invader.call_deferred()
	inv_num += 1
	if inv_num >= $GameField/Invaders.get_child_count():
		inv_num = 0
		# change move vector
		if move_dir == Invader.MoveDir.Down or need_change_dir:
			inv_move_dir_order +=1
			inv_move_dir_order %= Invader.move_dir_order.size()

		need_change_dir = false

func new_bullet(t :Bullet.Type, p :Vector2) -> Bullet:
	var o = bullet_scene.instantiate().init(t)
	$GameField/Bullets.add_child(o)
	o.position = p
	return o

func add_fighter_bullet() -> void:
	new_bullet(Bullet.Type.Fighter, $GameField/Fighter.position ).set_color($GameField/Fighter.get_color())

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
	if randi_range(0, 100) == 0:
		UFO_explode($GameField/UFO.position)

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
	$GameField/Fighter.position += fighter_mv_vt
	if randi_range(0, 100) == 0:
		fighter_explode($GameField/Fighter.position)
	if not get_gamefield_rect().has_point($GameField/Fighter.position):
		$GameField/Fighter.position = $GameField/Fighter.position.clamp(Vector2.ZERO, gamefield_size)
