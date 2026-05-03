extends Area2D

@export var piece_id := 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.collect_key_piece(piece_id)
		queue_free()
