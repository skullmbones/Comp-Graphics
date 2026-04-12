extends CanvasLayer

@onready var hp_bar: ProgressBar = $LeftMargin/VBoxContainer/HPBar
@onready var key_label: Label = $LeftMargin/VBoxContainer/KeyLabel
@onready var timer_label: Label = $TimerLabel

var max_hp := 10
var current_hp := 10
var keys := 0
var time_elapsed := 0.0

func _ready() -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	update_keys()
	update_timer_text()

func _process(delta: float) -> void:
	time_elapsed += delta
	update_timer_text()

func update_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_bar.value = current_hp

func add_key(amount: int = 1) -> void:
	keys += amount
	update_keys()

func use_key(amount: int = 1) -> bool:
	if keys >= amount:
		keys -= amount
		update_keys()
		return true
	return false

func update_keys() -> void:
	key_label.text = "Keys: " + str(keys)

func update_timer_text() -> void:
	timer_label.text = "Time: " + str(int(time_elapsed))
