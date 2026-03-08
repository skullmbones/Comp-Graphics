extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.use_key(1):
			win()
func win() -> void:
	$"../GameOver".win()
