extends CanvasLayer

@onready var hp_bar: ProgressBar = $LeftMargin/VBoxContainer/HPBar
@onready var timer_label: Label = $TimerLabel

@onready var key_piece_1: Sprite2D = $KeyHolder/KeyPiece1
@onready var key_piece_2: Sprite2D = $KeyHolder/KeyPiece2
@onready var key_piece_3: Sprite2D = $KeyHolder/KeyPiece3

var max_hp := 10
var current_hp := 10
var time_elapsed := 0.0

var has_piece_1 := false
var has_piece_2 := false
var has_piece_3 := false

func _ready() -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	update_key_display()
	update_timer_text()

func _process(delta: float) -> void:
	time_elapsed += delta
	update_timer_text()

func update_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_bar.value = current_hp

func collect_key_piece(piece_id: int) -> void:
	match piece_id:
		1:
			has_piece_1 = true
		2:
			has_piece_2 = true
		3:
			has_piece_3 = true

	update_key_display()

func has_full_key() -> bool:
	return has_piece_1 and has_piece_2 and has_piece_3

func use_full_key() -> bool:
	if has_full_key():
		has_piece_1 = false
		has_piece_2 = false
		has_piece_3 = false
		update_key_display()
		return true
	return false

func update_key_display() -> void:
	key_piece_1.visible = has_piece_1
	key_piece_2.visible = has_piece_2
	key_piece_3.visible = has_piece_3

func update_timer_text() -> void:
	timer_label.text = "Time: " + str(int(time_elapsed))
