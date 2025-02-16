extends Panel
class_name Game

signal ui_data_changed()
signal game_ended()

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")

func get_gamefield_rect() -> Rect2:
	return Rect2(Vector2.ZERO, size)
func get_gridsize() -> Vector2:
	return Vector2(size.x / Settings.Grid_X, size.y / Settings.Grid_Y)
func calc_grid_position(x :float, y :float) -> Vector2:
	var gridsize = get_gridsize()
	return Vector2(x*gridsize.x,y*gridsize.y)
func calc_invader_move_area() -> Rect2:
	return Rect2( calc_grid_position(1,1), calc_grid_position(Settings.Grid_X-2,Settings.Grid_Y-3))
func invader_move_down_limit() -> float:
	return calc_invader_move_area().end.y
func calc_fighter_move_area() -> Rect2:
	return Rect2( calc_grid_position(1,Settings.Grid_Y-2), calc_grid_position(Settings.Grid_X-2,Settings.Grid_Y))

func _ready() -> void:
	$Fighter.init()
	$Fighter.ended.connect(fighter_explode)
	$UFO.ended.connect(UFO_explode)

var stage : int
var score : int
var fighter_dead : int
var game_playing: bool

# limit fighter bullet count, rate
var last_fighter_bullet_fire_time : float # get_unix_time_from_system()
var current_fighter_bullet_count :int

var current_moving_invader_num : int
var invader_move_dir_order : int
var invader_need_change_dir :bool
var alive_invader_count : int

var automove_fighter :bool
var fighter_mv_vt :Vector2

func new_game() -> void:
	score = 0
	fighter_dead = 0
	stage = 1
	ui_data_changed.emit()
	clear_bullets()
	$Fighter.position = calc_grid_position(1,Settings.Grid_Y-1)
	$UFO.deinit()
	init_invader()
	game_playing = true

func game_end() -> void:
	game_playing = false
	game_ended.emit()

func next_stage() -> void:
	stage += 1
	ui_data_changed.emit()
	clear_bullets()
	$Fighter.position = calc_grid_position(1,Settings.Grid_Y-1)
	$UFO.deinit()
	init_invader()

func clear_bullets() -> void:
	current_fighter_bullet_count	 = 0
	for o in $Bullets.get_children():
		o.queue_free()

func init_invader() -> void:
	for o in $Invaders.get_children():
		o.queue_free()
	current_moving_invader_num = 0
	invader_move_dir_order = 0
	invader_need_change_dir = false
	Invader.set_move_vector(Vector2(20,20))

	var stage_y_inc = stage * Invader.get_move_vector(Invader.MoveDir.Down).y
	if stage_y_inc > calc_grid_position(0,Settings.Grid_Y-Settings.Invader_Rows.size()-2).y:
		stage_y_inc = calc_grid_position(0,Settings.Grid_Y-Settings.Invader_Rows.size()-4).y
	for j in Settings.Invader_Rows.size():
		for i in Settings.InvaderCount_X:
			var o = invader_scene.instantiate().init(Settings.Invader_Rows[j])
			$Invaders.add_child(o)
			o.position = calc_grid_position(i+1,j+2)
			o.position.y += stage_y_inc
			o.ended.connect(invader_explode)
	alive_invader_count = 5*Settings.InvaderCount_X

func invader_explode(inv :Invader) -> void:
	score += Invader.Score[inv.get_type()]
	ui_data_changed.emit()
	var pos = inv.position
	alive_invader_count -=1
	var o = explode_scene.instantiate().init(Explode.Type.Invader)
	o.position = pos
	$Explodes.add_child(o)
	o.ended.connect(end_explode)

func UFO_explode(ufo :UFO) -> void:
	score += ufo.get_score()
	ui_data_changed.emit()
	var pos = ufo.position
	var o = explode_scene.instantiate().init(Explode.Type.UFO)
	o.position = pos
	$Explodes.add_child(o)
	o.ended.connect(end_explode)

func fighter_explode(fighter :Fighter) -> void:
	$Fighter.deinit()
	fighter_dead += 1
	clear_bullets()
	ui_data_changed.emit()
	var pos = fighter.position
	var o = explode_scene.instantiate().init(Explode.Type.Fighter)
	o.position = pos
	$Explodes.add_child(o)
	o.ended.connect(end_explode)

func bullet_explode(bullet :Bullet) -> void:
	bullet.queue_free()
	if bullet.bullet_type == Bullet.Type.Fighter:
		current_fighter_bullet_count -=1

func end_explode(o :Explode) ->void:
	o.queue_free()
	if o.explode_type == Explode.Type.Fighter:
		$Fighter.init()
		$Fighter.position = calc_grid_position(1,Settings.Grid_Y-1)

func _process(_delta: float) -> void:
	if not game_playing :
		return
	if $UFO.valid:
		move_UFO()
	elif randi_range(0, 100) == 0:
		new_UFO()
	move_bullets()
	move_invaders()
	if automove_fighter:
		fighter_auto()
	move_fighter()

func fighter_auto() -> void:
	if not $Fighter.valid:
		return
	match randi_range(0,100):
		0,1,2,3,4:
			fighter_mv_vt = Vector2(-6,0)
		10:
			fighter_mv_vt = Vector2(0,0)
		20,21,22,23,24:
			fighter_mv_vt = Vector2(6,0)
		30,31,32,33,34,35:
			add_fighter_bullet()

func move_invaders() -> void:
	if alive_invader_count <= 0:
		print("win stage")
		next_stage.call_deferred()
		return

	while not $Invaders.get_child(current_moving_invader_num).visible :
		if invader_move_dir_next():
			return
	var o = $Invaders.get_child(current_moving_invader_num)

	var move_dir = Invader.move_dir_order[invader_move_dir_order]
	o.position += Invader.get_move_vector( move_dir )
	o.next_frame()
	if randi_range(0, 100) == 0:
		new_bullet(o.get_bullet_type(), o.position ).set_color(o.get_color())
	if not calc_invader_move_area().has_point(o.position):
		invader_need_change_dir = true
		if o.position.y > invader_move_down_limit():
			game_end()
	invader_move_dir_next()

func invader_move_dir_next() -> bool:
	current_moving_invader_num += 1
	var move_dir = Invader.move_dir_order[invader_move_dir_order]
	if current_moving_invader_num >= $Invaders.get_child_count():
		current_moving_invader_num = 0
		# change move vector
		if move_dir == Invader.MoveDir.Down or invader_need_change_dir:
			invader_move_dir_order +=1
			invader_move_dir_order %= Invader.move_dir_order.size()
		invader_need_change_dir = false
		return true
	return false

func new_bullet(t :Bullet.Type, p :Vector2) -> Bullet:
	var o = bullet_scene.instantiate().init(t)
	$Bullets.add_child(o)
	o.position = p
	o.ended.connect(bullet_explode)
	return o

func add_fighter_bullet() -> void:
	if (Time.get_unix_time_from_system() - last_fighter_bullet_fire_time) > Settings.BulletNextFireSec and current_fighter_bullet_count < Settings.BulletCountLimit:
		new_bullet(Bullet.Type.Fighter, $Fighter.position ).set_color($Fighter.get_color())
		last_fighter_bullet_fire_time = Time.get_unix_time_from_system()
		current_fighter_bullet_count +=1

func move_bullets() -> void:
	for o in $Bullets.get_children():
		o.position += o.get_move_vector()
		if not get_gamefield_rect().has_point(o.position):
			bullet_explode(o)

func new_UFO() -> void:
	var pos :Vector2
	var dir :UFO.MoveDir
	if randi_range(0, 1) == 0:
		pos = calc_grid_position(0,1)
		dir = UFO.MoveDir.Right
	else :
		pos = calc_grid_position( Settings.Grid_X,1)
		dir = UFO.MoveDir.Left
	$UFO.position = pos
	$UFO.init( dir, [UFO.MoveSpeed.Low, UFO.MoveSpeed.High].pick_random() )

func move_UFO() -> void:
	$UFO.position += $UFO.get_move_vector()
	if not get_gamefield_rect().has_point($UFO.position):
		$UFO.deinit()
	elif randi_range(0, 100) == 0:
		new_bullet(Bullet.Type.UFO, $UFO.position ).set_color($UFO.get_color())

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
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

func move_fighter() -> void:
	if not $Fighter.valid:
		return
	$Fighter.position += fighter_mv_vt
	var t = calc_fighter_move_area()
	if not t.has_point($Fighter.position):
		$Fighter.position = $Fighter.position.clamp(t.position, t.end)
