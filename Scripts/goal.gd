extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var hud = get_tree().get_first_node_in_group("hud")

		if hud and hud.use_full_key():
			open()
		else:
			print("You need all 3 key pieces!")

func open() -> void:
	var texture = load('res://ldtk/cageopen.png')
	$Sprite2D.texture = texture
	$StaticBody2D.queue_free()
