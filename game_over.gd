extends CanvasLayer

func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	self.hide()
	get_tree().change_scene_to_file("res://menu.tscn")

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
