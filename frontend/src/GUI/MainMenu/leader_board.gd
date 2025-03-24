class_name LeaderBoard
extends CanvasLayer

signal leaderboard_completed


@onready var score_list := %ScoreList
@onready var info := %info_board
@export var score_offset := 0
@export_range(1, 50) var score_limit := 10


func _ready() -> void:
	score_list.set_column_expand_ratio(1,2)
	score_list.set_column_expand_ratio(3,2)
	info.text = ""
	var column_names := ["Rank", "Name", "Score", "Time"]
	for column_index in range(column_names.size()):
		var cname: String = column_names[column_index]
		score_list.set_column_title(column_index, cname)
		score_list.set_column_title_alignment(column_index, HORIZONTAL_ALIGNMENT_LEFT)
		column_index += 1
	
	refresh_scores()
		

# Callback function when request is completed
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		info.text = ""
		var response_data = body.get_string_from_utf8()
		
		var json_as_dict = JSON.parse_string(response_data)
		var json = JSON.new()
		var result1 = json.parse(json_as_dict)
		
		if result1 == OK:
			var data_array = json.get_data()
		
			score_list.clear()
			var root: TreeItem = score_list.create_item()
			var i = 1
			for score in data_array:
				var row: TreeItem = score_list.create_item(root)
				row.set_text(0, str(i))
				row.set_text(1, str(score["username"]))
				row.set_text(2, str(score["score"]))
				row.set_text(3, str(score["timestamp"]))
				row.set_custom_bg_color(1, Color("#005216"))
				i=i+1
		
	else:
		info.text = "Leader board can not be accessed"
	
#refresh data by sending username and password
func refresh_scores():
		
	
	
	var url = Config.leaderboard_url
	#use formdata to send username and password
	var form_data = FormData.new()
	form_data.add_field("submission_type", Config.submission_type)
	form_data.add_field("username", "admin")
	form_data.add_field("pass", "admin")
	form_data.add_field("score", "0")
	form_data.add_field("APP", "gameleaderboard")
	
	var header = ["Content-Type: multipart/form-data; boundary=" + form_data.get_boundary()]
	var method = HTTPClient.METHOD_POST
	
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	info.text = "Retrieving..."
	http_request.request_completed.connect(_on_request_completed)
	http_request.request_raw(url, header, method, form_data.get_data())
	await http_request.request_completed
	#print(request_data)

func append_line(buffer:PackedByteArray, line:String) -> void:
	buffer.append_array(line.to_utf8_buffer())
	buffer.append_array('\r\n'.to_utf8_buffer())


func _on_exit_pressed() -> void:
	queue_free()
