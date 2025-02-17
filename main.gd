extends Node2D

var game_scene = preload("res://game.tscn")

var game_count := 0
var high_score := 0
var current_game :Game

func _ready() -> void:
	var vp_size = get_viewport_rect().size
	var game_size = Vector2(vp_size.x*0.7,vp_size.y)
	$UI.position = Vector2(game_size.x,0)
	$UI.size = Vector2(vp_size.x - game_size.x, vp_size.y)
	$PanelContainer.position = vp_size/2 - $PanelContainer.size /2
	start_demo()

func start_demo() -> void:
	$PanelContainer.show()
	start_game(true)

func start_game(demo_mode:bool) -> void:
	if current_game != null:
		current_game.queue_free()
		remove_child(current_game)
	var vp_size = get_viewport_rect().size
	var game_size = Vector2(vp_size.x*0.7,vp_size.y)
	current_game = game_scene.instantiate()
	current_game.position = Vector2(0,0)
	current_game.size = game_size
	current_game.ui_data_changed.connect(update_ui_data)
	current_game.game_ended.connect(start_demo)
	current_game.demo_mode = demo_mode
	add_child(current_game)
	game_count +=1
	current_game.start_game()

func update_ui_data() -> void:
	if current_game.score > high_score:
		high_score = current_game.score
	$UI/HighScore.text = "High Score %d" % high_score
	$UI/GameCount.text = "Game #%d" % game_count
	$UI/Stage.text = "Stage %d" % current_game.stage
	$UI/Score.text = "Score %d" % current_game.score
	$UI/Fighter.text = "Fighter dead %d" % current_game.fighter_dead

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		else:
			if $PanelContainer.visible:
				$PanelContainer.hide()
				start_game(false)
