extends CharacterBody2D

var bullet = preload("res://NPCs/Ghost/ghost_bullet.tscn")
@onready var player = null
var health = 50
var inrange = false
var attack = false

func _physics_process(delta: float) -> void:
	if !attack:
		$AnimatedSprite2D.play("walk")

func take_damage(amount) -> void:
	health -= amount
	$AnimatedSprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

	if health <= 0:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		take_damage(25)

func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		$cooldown.start(0.1)
		inrange = true
		
func shoot():
	var shot = bullet.instantiate()
	var dir = global_position.direction_to(player.global_position)
	shot.direction = dir
	shot.rotation = dir.angle()
	shot.rotation += PI
	shot.global_position = global_position
	get_tree().root.add_child(shot)

func _on_cooldown_timeout() -> void:
	if inrange:
		attack = true
		$AnimatedSprite2D.play("attack")
		shoot()
		$cooldown.start(1.5)

func _on_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		inrange = false
		attack = false
