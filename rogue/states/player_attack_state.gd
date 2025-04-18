class_name PlayerAttackState extends State

const SLASH = "Slash"

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null)
