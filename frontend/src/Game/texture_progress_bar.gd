extends TextureProgressBar

var bar_red = preload("res://assets/images/barHorizontal_red_mid 200.png")
var bar_green = preload("res://assets/images/barHorizontal_green_mid 200.png")
var bar_yellow = preload("res://assets/images/barHorizontal_yellow_mid 200.png")


func update_health(_value, _max_value):
	value = _value
	texture_progress = bar_green
	if _value < 0.75 * _max_value:
		texture_progress = bar_yellow
	if _value < 0.45 * _max_value:
		texture_progress = bar_red
