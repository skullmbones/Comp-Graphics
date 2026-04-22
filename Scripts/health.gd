extends ProgressBar

@export var player_path: NodePath
var player: Node = null

func _ready() -> void:
	player = get_node_or_null(player_path)

	if player == null:
		return

	min_value = 0
	step = 1
	max_value = player.max_health
	value = player.health

func _process(_delta: float) -> void:
	if player == null:
		return

	value = player.health
	max_value = player.max_health
