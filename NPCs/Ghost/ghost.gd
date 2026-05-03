extends CharacterBody2D

var bullet = preload("res://NPCs/Ghost/ghost_bullet.tscn")
var ghostheart = preload("res://Scenes/ghostheart.tscn")

@onready var player = null

var health = 10
var inrange = false
var attack = false
var dead = false


func _physics_process(delta: float) -> void:
	if dead:
		return

	if !attack:
		$AnimatedSprite2D.play("walk")


func take_damage(amount) -> void:
	if dead:
		return

	health -= amount
	print("Ghost took damage. Health is now: ", health)

	$AnimatedSprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.5).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

	if health <= 0:
		dead = true
		drop_ghostheart()
		queue_free()


func drop_ghostheart() -> void:
	var drop = ghostheart.instantiate()
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Something entered ghost damage area: ", area.name, " Groups: ", area.get_groups())

	if area.is_in_group("player_attack"):
		take_damage(20)


func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		$cooldown.start(0.1)
		inrange = true
		

func shoot():
	if player == null:
		return

	var shot = bullet.instantiate()
	var dir = global_position.direction_to(player.global_position)
	shot.direction = dir
	shot.rotation = dir.angle()
	shot.rotation += PI
	shot.global_position = global_position
	get_tree().root.add_child(shot)


func _on_cooldown_timeout() -> void:
	if inrange and player != null and !dead:
		attack = true
		$AnimatedSprite2D.play("attack")
		shoot()
		$cooldown.start(1.5)


func _on_vision_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		inrange = false
		attack = false
		player = null
