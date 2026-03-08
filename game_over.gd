extends CanvasLayer

func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func game_over():
	get_tree().paused = true
	self.show()
	
func win():
	get_tree().paused = true
	$Label.text = "You Win"
	$Retry.text = "Play Again"
	self.show()


func _on_quit_pressed() -> void:
	get_tree().quit()
