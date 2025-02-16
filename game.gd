extends Panel
class_name Game

signal score_changed()

const InvaderCount_X = 11
const GridCount_X = 13
const GridCount_Y = 12

var invader_scene = preload("res://invader.tscn")
var bullet_scene = preload("res://bullet.tscn")
var explode_scene = preload("res://explode.tscn")

func get_gamefield_rect() -> Rect2:
	return Rect2(Vector2.ZERO, size)
func get_gridsize() -> Vector2:
	return Vector2(size.x / GridCount_X, size.y / GridCount_Y)
func calc_grid_position(x :float, y :float) -> Vector2:
	var gridsize = get_gridsize()
	return Vector2(x*gridsize.x,y*gridsize.y)
func calc_invader_move_area() -> Rect2:
	return Rect2( calc_grid_position(1,1), calc_grid_position(GridCount_X-2,GridCount_Y-3))
func invader_move_down_limit() -> float:
	return calc_invader_move_area().end.y
func calc_fighter_move_area() -> Rect2:
	return Rect2( calc_grid_position(1,GridCount_Y-2), calc_grid_position(GridCount_X-2,GridCount_Y))

func _ready() -> void:
	$Fighter.init()
	$Fighter.ended.connect(fighter_explode)
	$UFO.ended.connect(UFO_explode)

var score := 0
var stage := 0
var fighter_dead := 0
func new_game() -> void:
	score = 0
	fighter_dead = 0
	stage = 0
	score_changed.emit()
	clear_bullets()
	$Fighter.position = calc_grid_position(1,GridCount_Y-1)
	$UFO.deinit()
	init_invader()

func next_stage() -> void:
	stage += 1
	score_changed.emit()
	clear_bullets()
	$Fighter.position = calc_grid_position(1,GridCount_Y-1)
	$UFO.deinit()
	init_invader()

func clear_bullets() -> void:
	for o in $Bullets.get_children():
		$Bullets.remove_child(o)

var inv_num := 0
var inv_move_dir_order := 0
var need_change_dir :bool
var alive_invader_count := 0
func init_invader() -> void:
	for o in $Invaders.get_children():
		$Invaders.remove_child(o)
	inv_num = 0
	inv_move_dir_order = 0
	need_change_dir = false
	Invader.set_move_vector(Vector2(20,20))

	for i in InvaderCount_X:
		var o = invader_scene.instantiate().init(Invader.Type.Invader3)
		$Invaders.add_child(o)
		o.position = calc_grid_position(i+1,2)

	for j in 2:
		for i in InvaderCount_X:
			var o = invader_scene.instantiate().init(Invader.Type.Invader2)
			$Invaders.add_child(o)
			o.position = calc_grid_position(i+1,j+3)

	for j in 2:
		for i in InvaderCount_X:
			var o = invader_scene.instantiate().init(Invader.Type.Invader1)
			$Invaders.add_child(o)
			o.position = calc_grid_position(i+1,j+5)

	for o in $Invaders.get_children():
		o.ended.connect(invader_explode)

	alive_invader_count = 5*InvaderCount_X

func invader_explode(inv :Invader) -> void:
	score += Invader.Score[inv.get_type()]
	score_changed.emit()
	var pos = inv.position
	alive_invader_count -=1
	var o = explode_scene.instantiate().init(Explode.Type.Invader)
	o.position = pos
	$Explodes.add_child(o)
	o.ended.connect(end_explode)

func UFO_explode(ufo :UFO) -> void:
	score += ufo.score
	score_changed.emit()
	var pos = ufo.position
	var o = explode_scene.instantiate().init(Explode.Type.UFO)
	o.position = pos
	$Explodes.add_child(o)
	o.ended.connect(end_explode)

func fighter_explode(fighter :Fighter) -> void:
	$Fighter.deinit()
	fighter_dead += 1
	var pos = fighter.position
	var o = explode_scene.instantiate().init(Explode.Type.Fighter)
	o.position = pos
	$Explodes.add_child(o)
	o.ended.connect(end_explode)

func bullet_explode(bullet :Bullet) -> void:
	$Bullets.remove_child.call_deferred(bullet)
	if bullet.bullet_type == Bullet.Type.Fighter:
		current_fighter_bullet_count -=1

func end_explode(o :Explode) ->void:
	$Explodes.remove_child(o)
	if o.explode_type == Explode.Type.Fighter:
		$Fighter.init()
		$Fighter.position = calc_grid_position(1,GridCount_Y-1)

func _process(_delta: float) -> void:
	if $UFO.visible:
		move_UFO()
	elif randi_range(0, 100) == 0:
		new_UFO()
	move_bullets()
	move_invaders()
	if automove_fighter:
		fighter_auto()
	move_fighter()

var automove_fighter :bool = true
func fighter_auto() -> void:
	match randi_range(0,100):
		0,1,2,3,4:
			fighter_mv_vt = Vector2(-6,0)
		10:
			fighter_mv_vt = Vector2(0,0)
		20,21,22,23,24:
			fighter_mv_vt = Vector2(6,0)
		30:
			add_fighter_bullet()

func move_invaders() -> void:
	if alive_invader_count <= 0:
		print("win stage")
		next_stage.call_deferred()
		return

	while not $Invaders.get_child(inv_num).visible :
		if invader_move_dir_next():
			return
	var o = $Invaders.get_child(inv_num)

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
	if inv_num >= $Invaders.get_child_count():
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
	$Bullets.add_child(o)
	o.position = p
	o.ended.connect(bullet_explode)
	return o

# limit fighter bullet count, rate
var last_fighter_bullet_fire_time : float # get_unix_time_from_system()
var current_fighter_bullet_count :int
func add_fighter_bullet() -> void:
	if (Time.get_unix_time_from_system() - last_fighter_bullet_fire_time) > Fighter.BulletNextFireSec and current_fighter_bullet_count < Fighter.BulletCountLimit:
		new_bullet(Bullet.Type.Fighter, $Fighter.position ).set_color($Fighter.get_color())
		last_fighter_bullet_fire_time = Time.get_unix_time_from_system()
		current_fighter_bullet_count +=1

func move_bullets() -> void:
	for o in $Bullets.get_children():
		o.position += o.get_move_vector()
		if not get_gamefield_rect().has_point(o.position):
			bullet_explode(o)

func new_UFO() -> void:
	if randi_range(0, 1) == 0:
		$UFO.position = calc_grid_position(0,1)
	else :
		$UFO.position = calc_grid_position( GridCount_X,1)
	$UFO.init()

func move_UFO() -> void:
	$UFO.position += $UFO.get_move_vector()
	if not get_gamefield_rect().has_point($UFO.position):
		$UFO.deinit()
	elif randi_range(0, 100) == 0:
		new_bullet(Bullet.Type.UFO, $UFO.position ).set_color($UFO.get_color())

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
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
	$Fighter.position += fighter_mv_vt
	var t = calc_fighter_move_area()
	if not t.has_point($Fighter.position):
		$Fighter.position = $Fighter.position.clamp(t.position, t.end)
