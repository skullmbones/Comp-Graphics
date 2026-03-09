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
	var new_texture: Texture2D = load("res://Assets/youwinscreen.png")
	get_tree().paused = true
	$TextureRect.texture = new_texture
	self.show()


func _on_quit_pressed() -> void:
	get_tree().quit()
