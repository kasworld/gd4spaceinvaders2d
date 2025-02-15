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
	$UI.position = Vector2(gamefield_size.x,0)
	$UI.size = Vector2(vp_size.x - gamefield_size.x, vp_size.y)

	$GameField/Fighter.init()
	$GameField/Fighter.position = calc_grid_position(5,GridCount_Y-1)
	$GameField/Fighter.ended.connect(fighter_explode)

	$GameField/UFO.ended.connect(UFO_explode)

	new_game()

var score := 0
func new_game() -> void:
	score = 0
	update_score()
	clear_bullet()
	$GameField/UFO.deinit()
	init_invader()

func next_stage() -> void:
	clear_bullet()
	$GameField/UFO.deinit()
	init_invader()

func clear_bullet() -> void:
	for o in $GameField/Bullets.get_children():
		$GameField/Bullets.remove_child(o)

var inv_num := 0
var inv_move_dir_order := 0
var need_change_dir :bool
var alive_invader_count := 0
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

	for o in $GameField/Invaders.get_children():
		o.ended.connect(invader_explode)

	alive_invader_count = 5*InvaderCount_X

func update_score() -> void:
	$UI/Score.text = "Score %d" % score

func invader_explode(inv :Invader) -> void:
	score += Invader.Score[inv.get_type()]
	update_score()
	var pos = inv.position
	alive_invader_count -=1
	var o = explode_scene.instantiate().init(Explode.Type.Invader)
	o.position = pos
	$GameField/Explodes.add_child(o)
	o.ended.connect(end_explode)

func UFO_explode(ufo :UFO) -> void:
	score += ufo.score
	update_score()
	var pos = ufo.position
	var o = explode_scene.instantiate().init(Explode.Type.UFO)
	o.position = pos
	$GameField/Explodes.add_child(o)
	o.ended.connect(end_explode)

func fighter_explode(fighter :Fighter) -> void:
	var pos = fighter.position
	var o = explode_scene.instantiate().init(Explode.Type.Fighter)
	o.position = pos
	$GameField/Explodes.add_child(o)
	o.ended.connect(end_explode)

func bullet_explode(bullet :Bullet) -> void:
	$GameField/Bullets.remove_child.call_deferred(bullet)

func end_explode(o :Explode) ->void:
	$GameField/Explodes.remove_child(o)

func _process(_delta: float) -> void:
	if $GameField/UFO.visible:
		move_UFO()
	elif randi_range(0, 100) == 0:
		new_UFO()
	move_bullets()
	move_invaders()
	move_fighter()

func move_invaders() -> void:
	if alive_invader_count <= 0:
		print("win stage")
		next_stage.call_deferred()
		return

	while not $GameField/Invaders.get_child(inv_num).visible :
		if invader_move_dir_next():
			return
	var o = $GameField/Invaders.get_child(inv_num)

	var move_dir = Invader.move_dir_order[inv_move_dir_order]
	o.position += Invader.get_move_vector( move_dir )
	o.next_frame()
	if randi_range(0, 100) == 0:
		new_bullet(o.get_bullet_type(), o.position ).set_color(o.get_color())
	if not calc_invader_move_area().has_point(o.position):
		need_change_dir = true
		if o.position.y > invader_move_down_limit():
			print("lose game")
			new_game.call_deferred()
	invader_move_dir_next()

func invader_move_dir_next() -> bool:
	inv_num += 1
	var move_dir = Invader.move_dir_order[inv_move_dir_order]
	if inv_num >= $GameField/Invaders.get_child_count():
		inv_num = 0
		# change move vector
		if move_dir == Invader.MoveDir.Down or need_change_dir:
			inv_move_dir_order +=1
			inv_move_dir_order %= Invader.move_dir_order.size()
		need_change_dir = false
		return true
	return false

func new_bullet(t :Bullet.Type, p :Vector2) -> Bullet:
	var o = bullet_scene.instantiate().init(t)
	$GameField/Bullets.add_child(o)
	o.position = p
	o.ended.connect(bullet_explode)
	return o

func add_fighter_bullet() -> void:
	new_bullet(Bullet.Type.Fighter, $GameField/Fighter.position ).set_color($GameField/Fighter.get_color())

func move_bullets() -> void:
	for o in $GameField/Bullets.get_children():
		o.position += o.get_move_vector()
		if not get_gamefield_rect().has_point(o.position):
			bullet_explode(o)

func new_UFO() -> void:
	if randi_range(0, 1) == 0:
		$GameField/UFO.position = calc_grid_position(0,1)
	else :
		$GameField/UFO.position = calc_grid_position( GridCount_X,1)
	$GameField/UFO.init()

func move_UFO() -> void:
	$GameField/UFO.position += $GameField/UFO.get_move_vector()
	if not get_gamefield_rect().has_point($GameField/UFO.position):
		$GameField/UFO.deinit()
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
	$GameField/Fighter.position += fighter_mv_vt
	if not get_gamefield_rect().has_point($GameField/Fighter.position):
		$GameField/Fighter.position = $GameField/Fighter.position.clamp(Vector2.ZERO, gamefield_size)
