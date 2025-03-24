extends SubViewport

func _ready() -> void:
	world_2d = get_tree().root.world_2d
	get_tree().root.set_canvas_cull_mask_bit(1, false)

func _process(delta: float) -> void:
	$Camera2D.position = $%Game.player.grid_position
