extends Node2D

var game_count := 0

func _ready() -> void:
	var vp_size = get_viewport_rect().size
	var gamefield_size = Vector2(vp_size.x*0.7,vp_size.y)
	$Game.position = Vector2(0,0)
	$Game.size = gamefield_size
	$UI.position = Vector2(gamefield_size.x,0)
	$UI.size = Vector2(vp_size.x - gamefield_size.x, vp_size.y)
	$Game.ui_data_changed.connect(update_ui_data)
	$Game.game_ended.connect(start_game)
	start_game()

func start_game() -> void:
	game_count +=1
	$Game.new_game()

func update_ui_data() -> void:
	$UI/Score.text = "Score %d" % $Game.score
	$UI/Fighter.text = "Fighter dead %d" % $Game.fighter_dead
	$UI/Stage.text = "Stage %d" % $Game.stage
	$UI/GameCount.text = "Game #%d" % game_count

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER:
			_on_demo_mode_pressed()

func _on_demo_mode_pressed() -> void:
	$Game.automove_fighter = not $Game.automove_fighter
	if $Game.automove_fighter:
		$UI/DemoMode.text = "Auto control"
	else :
		$UI/DemoMode.text = "Key control"
	$Game.grab_focus.call_deferred()
