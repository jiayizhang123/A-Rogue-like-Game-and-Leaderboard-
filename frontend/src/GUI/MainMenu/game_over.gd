class_name GameOverMenu
extends CanvasLayer
@onready var score := %Score
@onready var username := %name_LineEdit
@onready var password := %password_LineEdit
@onready var info := %Info
const leaderBoard_scene: PackedScene = preload("res://src/GUI/MainMenu/leaderBoard.tscn")

func _ready() -> void:
	score.text = str(Config.score)
	username.text = Config.username
	password.text = Config.password
	info.text = ""
	$CenterContainer/PanelContainer/VBoxContainer/submit_score.disabled = false


func _on_submit_score_pressed() -> void:
	Config.username = username.text
	Config.password = password.text 
	var url = Config.leaderboard_url
	
	
	
	var form_data = FormData.new()
	form_data.add_field("submission_type", Config.submission_type)
	form_data.add_field("username", Config.username)
	form_data.add_field("pass", Config.password)
	form_data.add_field("score", str(Config.score))
	form_data.add_field("APP", "gameover")
	info.text = "Sending..."
	$CenterContainer/PanelContainer/VBoxContainer/submit_score.disabled = true
	var header = ["Content-Type: multipart/form-data; boundary=" + form_data.get_boundary()]
	var method = HTTPClient.METHOD_POST
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var error = http_request.request_raw(url, header, method, form_data.get_data())
	await http_request.request_completed
	
func _on_request_completed(result, response_code, headers, body):
	
	if response_code != 200:
		info.text = "Score can not be submitted"
		$CenterContainer/PanelContainer/VBoxContainer/submit_score.disabled = false
	else:
		info.text = "Score is submitted"


func _on_leader_board_pressed() -> void:
	var leaderBoard: LeaderBoard = leaderBoard_scene.instantiate()
	add_child(leaderBoard)
	#leaderBoard.setup(player)
	set_physics_process(false)
	await leaderBoard.leaderboard_completed
	set_physics_process.bind(true).call_deferred()


func _on_new_game_2_pressed() -> void:
	SignalBus.escape_requested.emit()


func _on_quit_pressed() -> void:
	get_tree().quit()
