extends CharacterBody2D

signal health_changed(current_health, max_health)

@export var walk_speed = 200
@export var sprint_speed = 300
@export var jump_velocity = -400

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_health = 10
var health = 10
var screen_size
var attacking = false

# -----------------------------
# UNDERWATER SETTINGS
# -----------------------------
var is_underwater: bool = false
var active_water_gravity: float = 120.0
var active_swim_speed: float = 150.0
var active_water_walk_speed: float = 115.0
var active_water_drag: float = 900.0
var active_max_sink_speed: float = 90.0
var active_water_current: Vector2 = Vector2.ZERO


func _ready() -> void:
	screen_size = get_viewport_rect().size

	add_to_group("player")

	$Hurtbox.add_to_group("player_hurtbox")
	$Hurtbox.monitoring = true
	$Hurtbox.monitorable = true

	$Hitbox.add_to_group("player_attack")
	$Hitbox.monitoring = true
	$Hitbox.monitorable = true
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/Sprite2D.visible = false

	emit_signal("health_changed", health, max_health)
	call_deferred("_update_hud_health")


func _physics_process(delta: float) -> void:
	var speed: float = walk_speed
	var direction := Input.get_axis("move_left", "move_right")

	if is_underwater:
		# Water gravity / sinking
		velocity.y += active_water_gravity * delta

		# Swim upward using your normal jump input
		if Input.is_action_pressed("move_jump"):
			velocity.y = move_toward(velocity.y, -active_swim_speed, active_water_drag * delta)

		# Optional downward swim if you add "move_down" in Input Map
		if InputMap.has_action("move_down") and Input.is_action_pressed("move_down"):
			velocity.y = move_toward(velocity.y, active_swim_speed, active_water_drag * delta)

		velocity.y += active_water_current.y * delta
		velocity.y = clamp(velocity.y, -active_swim_speed, active_max_sink_speed)

		speed = active_water_walk_speed
	else:
		if not is_on_floor():
			velocity.y += gravity * delta

		if Input.is_action_just_pressed("move_jump") and is_on_floor():
			velocity.y = jump_velocity

		if Input.is_action_pressed("Sprint"):
			speed = sprint_speed
		else:
			speed = walk_speed

	if direction == 1 and not attacking:
		$AnimatedSprite2D.flip_h = false
		$Hitbox.scale.x = 1
	elif direction == -1 and not attacking:
		$AnimatedSprite2D.flip_h = true
		$Hitbox.scale.x = -1

	if Input.is_action_just_pressed("Attack") and not attacking:
		attacking = true
		$AnimatedSprite2D.play("attack")

		# Freeze horizontal movement for the attack
		velocity.x = 0

		# Keep these OFF until the attack animation reaches frame 3
		$Hitbox/Sprite2D.visible = false
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)

		# Only start cooldown here
		$Hitbox/CooldownTimer.start()

	if attacking:
		# Prevent sliding during attack animation
		velocity.x = 0
	else:
		if direction != 0:
			if is_underwater:
				var target_x := direction * speed + active_water_current.x
				velocity.x = move_toward(velocity.x, target_x, active_water_drag * delta)
			else:
				velocity.x = direction * speed

			if speed == walk_speed:
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("sprint")
		else:
			if is_underwater:
				velocity.x = move_toward(velocity.x, active_water_current.x, active_water_drag * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, walk_speed)

			$AnimatedSprite2D.play("default")

	move_and_slide()

func _update_hud_health() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_hp(health)

func hit(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_hp(health)

	emit_signal("health_changed", health, max_health)

	if health <= 0:
		_die()


func _die() -> void:
	$AnimatedSprite2D.queue_free()
	$"../GameOver".game_over()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	pass


func _on_cooldown_timer_timeout() -> void:
	attacking = false


func _on_attack_timer_timeout() -> void:
	$Hitbox/Sprite2D.visible = false
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)


func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "attack" and $AnimatedSprite2D.frame == 3:
		$Hitbox/CollisionShape2D.set_deferred("disabled", false)
		$Hitbox/AttackTimer.start()


func _on_animated_sprite_2d_animation_changed() -> void:
	if $AnimatedSprite2D.animation == "attack" and $AnimatedSprite2D.flip_h == false:
		$AnimatedSprite2D.offset = Vector2(7.5, 0)
	elif $AnimatedSprite2D.animation == "attack" and $AnimatedSprite2D.flip_h == true:
		$AnimatedSprite2D.offset = Vector2(-7.5, 0)
	else:
		$AnimatedSprite2D.offset = Vector2.ZERO


func enter_water(settings: Dictionary = {}) -> void:
	is_underwater = true

	active_water_gravity = settings.get("water_gravity", 120.0)
	active_swim_speed = settings.get("swim_speed", 150.0)
	active_water_walk_speed = settings.get("water_walk_speed", 115.0)
	active_water_drag = settings.get("water_drag", 900.0)
	active_max_sink_speed = settings.get("max_sink_speed", 90.0)
	active_water_current = settings.get("current", Vector2.ZERO)

	# Optional: soften the entry so the player does not slam downward into water.
	velocity.y = min(velocity.y, active_max_sink_speed)


func exit_water() -> void:
	is_underwater = false

	# Optional: small upward pop when leaving water.
	if velocity.y < 0:
		velocity.y *= 0.75
