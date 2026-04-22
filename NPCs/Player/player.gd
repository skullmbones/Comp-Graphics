extends CharacterBody2D

signal health_changed(current_health, max_health)

@export var walk_speed = 200
@export var sprint_speed = 300
@export var jump_velocity = -400
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_health = 100
var health = 100
var screen_size
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	add_to_group("player")
	$Hitbox.add_to_group("player_attack")
	$Hitbox.monitoring = true
	$Hitbox.monitorable = true
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	emit_signal("health_changed", health, max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var speed = walk_speed
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_pressed("Sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed
	var direction = Input.get_axis("move_left", "move_right")
	if direction == 1 and not attacking:
		get_node("AnimatedSprite2D").flip_h = false
		$Hitbox.scale.x = 1
	elif direction == -1 and not attacking:
		get_node("AnimatedSprite2D").flip_h = true
		$Hitbox.scale.x = -1
	if direction and not attacking:
		velocity.x = direction * speed
		if speed == walk_speed:
			$AnimatedSprite2D.play("walk")
		elif speed == sprint_speed:
			$AnimatedSprite2D.play("sprint")
	elif not attacking:
		velocity.x = move_toward(velocity.x, 0, speed)
		$AnimatedSprite2D.play("default")
		
	if Input.is_action_just_pressed("Attack") and not attacking:
		attacking = true
		#attack animation
		velocity.x = 0
		$AnimatedSprite2D.play("attack")
		$Hitbox/CooldownTimer.start()
		
	move_and_slide()
	
func hit(amount) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)
	print(health)

	if health <= 0:
		_die()
	
func _die() -> void:
	#TODO: Replace with actual game over
	$AnimatedSprite2D.queue_free()
	$"../GameOver".game_over()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		pass
		
func _on_cooldown_timer_timeout() -> void:
	attacking = false

func _on_attack_timer_timeout() -> void:
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
