extends Area2D
var collected = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and collected:
		win()

func win() -> void:
	$"../GameOver".win()

func _on_objective_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected = true
