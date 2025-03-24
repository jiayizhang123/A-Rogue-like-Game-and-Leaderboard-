extends Node

const game_scene: PackedScene = preload("res://src/Game/game.tscn")
const main_menu_scene: PackedScene = preload("res://src/GUI/MainMenu/main_menu.tscn")
const leaderBoard_scene: PackedScene = preload("res://src/GUI/MainMenu/leaderBoard.tscn")

var current_child: Node
var audio_player

func _ready():
	load_main_menu()
	audio_player = AudioStreamPlayer.new() 
	add_child(audio_player)
	audio_player.stream = load('res://assets/sounds/templateswise-1003.mp3')
	audio_player.stream.loop = true
	audio_player.play()


func load_main_menu() -> void:
	var main_menu: MainMenu = switch_to_scene(main_menu_scene)
	main_menu.game_requested.connect(_on_game_requested)


func switch_to_scene(scene: PackedScene) -> Node:
	if current_child != null:
		current_child.queue_free()
	current_child = scene.instantiate()
	add_child(current_child)
	return current_child


func _on_game_requested(try_load: bool) -> void:
	#var game: GameRoot = switch_to_scene(game_scene)
	#game.main_menu_requested.connect(load_main_menu)
	if try_load:
		var leaderBoard: LeaderBoard = leaderBoard_scene.instantiate()
		add_child(leaderBoard)
		#leaderBoard.setup(player)
		set_physics_process(false)
		await leaderBoard.leaderboard_completed
		set_physics_process.bind(true).call_deferred()
	else:
		var game: GameRoot = switch_to_scene(game_scene)
		game.main_menu_requested.connect(load_main_menu)
		game.new_game()
