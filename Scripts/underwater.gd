# WaterZone.gd
extends Area2D

@export var water_gravity: float = 120.0
@export var swim_speed: float = 150.0
@export var water_walk_speed: float = 115.0
@export var water_drag: float = 900.0
@export var max_sink_speed: float = 90.0
@export var current: Vector2 = Vector2.ZERO

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("enter_water"):
		body.enter_water({
			"water_gravity": water_gravity,
			"swim_speed": swim_speed,
			"water_walk_speed": water_walk_speed,
			"water_drag": water_drag,
			"max_sink_speed": max_sink_speed,
			"current": current
		})

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("exit_water"):
		body.exit_water()
