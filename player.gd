extends CharacterBody2D

@export var speed = 200
@export var jump_velocity = -500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_health = 100
var health = 100
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	elif direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	if direction:
		velocity.x = direction * speed
		$AnimatedSprite2D.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		$AnimatedSprite2D.play("default")

	position = position.clamp(Vector2.ZERO, screen_size)
		
	move_and_slide()
	
func hit(amount) -> void:
	health -= amount
	health = clamp(health, 0, max_health)
	if health <= 0:
		_die()
	
func _die() -> void:
	#TODO: Replace with actual game over
	queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	hit(100) #Change with actual enemy damage values
