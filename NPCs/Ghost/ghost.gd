extends CharacterBody2D

var bullet = preload("res://NPCs/Ghost/ghost_bullet.tscn")
var ghostheart = preload("res://NPCs/Ghost/ghostheart.tscn")

@onready var player = null

var health = 10
var inrange = false
var attack = false
var dead = false
var can_take_damage = true


func _ready() -> void:
	# Your ghost damage Area2D is named exactly "Area2D".
	if has_node("Area2D"):
		var hurtbox: Area2D = $Area2D
		hurtbox.monitoring = true
		hurtbox.monitorable = true

		# Broad mask while debugging so it can see the player's Hitbox.
		hurtbox.collision_mask = 0xFFFFFFFF

		if not hurtbox.area_entered.is_connected(_on_area_2d_area_entered):
			hurtbox.area_entered.connect(_on_area_2d_area_entered)

		print("Ghost hurtbox ready: ", hurtbox.name)
	else:
		print("ERROR: Ghost has no child named Area2D for damage.")


func _physics_process(_delta: float) -> void:
	if dead:
		return

	if !attack:
		$AnimatedSprite2D.play("walk")

	# Backup check in case Hitbox was already overlapping when it became active.
	_check_sword_overlap()


func _check_sword_overlap() -> void:
	if dead:
		return

	if !can_take_damage:
		return

	if !has_node("Area2D"):
		return

	var hurtbox: Area2D = $Area2D

	for area in hurtbox.get_overlapping_areas():
		if _is_player_sword_hitbox(area):
			take_damage(10)
			return


func take_damage(amount) -> void:
	if dead:
		return

	if !can_take_damage:
		return

	can_take_damage = false
	health -= amount
	print("Ghost took damage. Health is now: ", health)

	$AnimatedSprite2D.modulate = Color(1, 0, 0)

	if health <= 0:
		die()
		return

	await get_tree().create_timer(0.1).timeout

	if dead:
		return

	$AnimatedSprite2D.modulate = Color(1, 1, 1)

	await get_tree().create_timer(0.25).timeout

	if !dead:
		can_take_damage = true


func die() -> void:
	if dead:
		return

	# Save the exact position BEFORE disabling/freeing the ghost.
	var heart_drop_position: Vector2 = global_position

	# If you want it to match the visible sprite more closely, use this instead:
	if has_node("AnimatedSprite2D"):
		heart_drop_position = $AnimatedSprite2D.global_position

	# Slightly above the ghost so it is visible and not inside the floor.
	heart_drop_position += Vector2(0, -12)

	dead = true
	can_take_damage = false
	inrange = false
	attack = false
	player = null

	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)

	if has_node("vision"):
		$vision.set_deferred("monitoring", false)
		$vision.set_deferred("monitorable", false)

	print("Ghost died at: ", global_position)
	print("Heart should drop at: ", heart_drop_position)

	drop_ghostheart(heart_drop_position)

	call_deferred("queue_free")


func drop_ghostheart(drop_position: Vector2) -> void:
	var drop = ghostheart.instantiate()

	var parent_node = get_parent()
	if parent_node == null:
		parent_node = get_tree().current_scene

	if parent_node == null:
		print("ERROR: Could not drop ghostheart. No parent/current_scene found.")
		return

	# Add first, then set global_position.
	# This avoids wrong placement caused by parent transforms.
	parent_node.add_child(drop)
	drop.global_position = drop_position
	drop.z_index = 100
	drop.visible = true

	print("Ghostheart actually dropped at: ", drop.global_position)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area == null:
		return

	print("Something entered ghost damage area: ", area.name, " Groups: ", area.get_groups())

	if _should_ignore_area(area):
		return

	if _is_player_sword_hitbox(area):
		take_damage(10)


func _should_ignore_area(area: Area2D) -> bool:
	if area == null:
		return true

	var lower_name = area.name.to_lower()

	# Ignore ghost's own vision area.
	if lower_name == "vision":
		return true

	# Ignore ghost bullets.
	if lower_name.contains("ghostbullet") or lower_name.contains("ghost_bullet"):
		return true

	var parent = area.get_parent()
	if parent != null:
		var parent_name = parent.name.to_lower()

		if parent_name.contains("ghostbullet") or parent_name.contains("ghost_bullet"):
			return true

	return false


func _is_player_sword_hitbox(area: Area2D) -> bool:
	if area == null:
		return false

	var lower_name = area.name.to_lower()

	# Your player's sword Area2D is named Hitbox.
	if lower_name != "hitbox":
		# Also allow this if you later add the group manually.
		if not area.is_in_group("player_attack"):
			return false

	# Make sure this Hitbox belongs to the Player, not a random enemy/bullet.
	var node = area.get_parent()

	while node != null:
		if node.is_in_group("player"):
			return true

		node = node.get_parent()

	# Backup: if you manually add player_attack group, accept it.
	if area.is_in_group("player_attack"):
		return true

	return false


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
