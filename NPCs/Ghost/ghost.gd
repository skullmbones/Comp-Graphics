extends CharacterBody2D

var bullet = preload("res://NPCs/Ghost/ghost_bullet.tscn")
var ghostheart = preload("res://Scenes/ghostheart.tscn")

@onready var player = null

var health = 10
var inrange = false
var attack = false
var dead = false

var can_take_damage = true
var player_touching_hurtbox: Node2D = null

# Add your player's attack animation names here if different.
var player_attack_animation_names = [
	"attack",
	"slash",
	"sword",
	"melee",
	"hit"
]


func _ready() -> void:
	if has_node("Area2D"):
		var hurtbox: Area2D = $Area2D
		hurtbox.monitoring = true
		hurtbox.monitorable = true

		if not hurtbox.area_entered.is_connected(_on_area_2d_area_entered):
			hurtbox.area_entered.connect(_on_area_2d_area_entered)

		if not hurtbox.body_entered.is_connected(_on_area_2d_body_entered):
			hurtbox.body_entered.connect(_on_area_2d_body_entered)

		if not hurtbox.body_exited.is_connected(_on_area_2d_body_exited):
			hurtbox.body_exited.connect(_on_area_2d_body_exited)

		print("Ghost hurtbox ready: ", hurtbox.name)
	else:
		print("ERROR: Ghost has no child named Area2D for damage.")


func _physics_process(_delta: float) -> void:
	if dead:
		return

	if !attack:
		$AnimatedSprite2D.play("walk")

	_check_player_attack_overlap()


func _check_player_attack_overlap() -> void:
	if dead:
		return

	if !can_take_damage:
		return

	if player_touching_hurtbox == null:
		return

	if _is_player_attacking(player_touching_hurtbox):
		take_damage(10)


func _is_player_attacking(player_node: Node) -> bool:
	if player_node == null:
		return false

	# Best option: if your player.gd has a method called is_attacking().
	if player_node.has_method("is_attacking"):
		return player_node.is_attacking()

	# Check common boolean variable names on the player.
	if _has_property(player_node, "is_attacking") and player_node.get("is_attacking") == true:
		return true

	if _has_property(player_node, "attacking") and player_node.get("attacking") == true:
		return true

	if _has_property(player_node, "attack") and player_node.get("attack") == true:
		return true

	# Check player's current animation name.
	var sprite = _find_animated_sprite(player_node)

	if sprite != null:
		var current_anim = sprite.animation.to_lower()

		for attack_anim in player_attack_animation_names:
			if current_anim.contains(attack_anim):
				return true

	return false


func _find_animated_sprite(node: Node) -> AnimatedSprite2D:
	if node == null:
		return null

	if node is AnimatedSprite2D:
		return node

	for child in node.get_children():
		var result = _find_animated_sprite(child)
		if result != null:
			return result

	return null


func _has_property(node: Object, property_name: String) -> bool:
	for prop in node.get_property_list():
		if prop.name == property_name:
			return true

	return false


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

	dead = true
	can_take_damage = false
	inrange = false
	attack = false
	player = null
	player_touching_hurtbox = null

	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)

	if has_node("vision"):
		$vision.set_deferred("monitoring", false)
		$vision.set_deferred("monitorable", false)

	drop_ghostheart()
	call_deferred("queue_free")


func drop_ghostheart() -> void:
	var drop = ghostheart.instantiate()
	drop.global_position = global_position

	if get_tree().current_scene != null:
		get_tree().current_scene.call_deferred("add_child", drop)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area == null:
		return

	print("Something entered ghost damage area: ", area.name, " Groups: ", area.get_groups())

	if _should_ignore_area(area):
		return

	# If you eventually add a real player attack Area2D, this will still support it.
	if area.is_in_group("player_attack"):
		take_damage(10)
		return


func _on_area_2d_body_entered(body: Node2D) -> void:
	if dead:
		return

	if body == null:
		return

	print("Something entered ghost damage body area: ", body.name, " Groups: ", body.get_groups())

	if body.is_in_group("player"):
		player_touching_hurtbox = body

		# If the player enters while already attacking, damage immediately.
		if _is_player_attacking(body):
			take_damage(10)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_touching_hurtbox:
		player_touching_hurtbox = null


func _should_ignore_area(area: Area2D) -> bool:
	if area == null:
		return true

	var lower_name = area.name.to_lower()

	if lower_name == "vision":
		return true

	if lower_name.contains("ghostbullet") or lower_name.contains("ghost_bullet"):
		return true

	var parent = area.get_parent()

	if parent != null:
		var parent_name = parent.name.to_lower()

		if parent_name.contains("ghostbullet") or parent_name.contains("ghost_bullet"):
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
