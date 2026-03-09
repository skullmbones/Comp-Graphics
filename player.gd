extends CharacterBody2D

@export var walk_speed = 200
@export var sprint_speed = 300
@export var jump_velocity = -500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_health = 100
var health = 100
var screen_size
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


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
	if direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		$Hitbox.scale.x = 1
	elif direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
		$Hitbox.scale.x = -1
	if direction:
		velocity.x = direction * speed
		if speed == walk_speed:
			$AnimatedSprite2D.play("walk")
		elif speed == sprint_speed:
			$AnimatedSprite2D.play("sprint")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		$AnimatedSprite2D.play("default")
		
	if Input.is_action_just_pressed("Attack") and not attacking:
		attacking = true
		#attack animation
		$Hitbox/CooldownTimer.start()
		$Hitbox/Sprite2D.visible = true
		$Hitbox.monitorable = true
		
	position = position.clamp(Vector2.ZERO, screen_size)
		
	move_and_slide()
	
func hit(amount) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	if health <= 0:
		_die()
	
func _die() -> void:
	#TODO: Replace with actual game over
	$AnimatedSprite2D.queue_free()
	$"../GameOver".game_over()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	hit(100) #Change with actual enemy damage values

func _on_cooldown_timer_timeout() -> void:
	attacking = false
	$Hitbox/Sprite2D.visible = false
	$Hitbox.monitorable = false
