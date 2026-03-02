extends CharacterBody2D

enum State { PATROL, CHASE }
var state: State = State.PATROL

@export var patrol_speed := 60.0
@export var chase_speed := 95.0
@export var gravity := 1200.0

@export var stop_distance := 18.0         
@export var leash_distance := 260.0       
@export var turn_cooldown := 0.12        

var dir := -1
var _turn_lock := 0.0
var player: Node2D = null

@onready var ground_ray: RayCast2D = $ground
@onready var wall_ray: RayCast2D = $wall
@onready var vision: Area2D = $vision

func _ready() -> void:
	_apply_dir_to_rays()

	# Vision events
	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	_turn_lock = max(0.0, _turn_lock - delta)

	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()
			
	if velocity.x > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
	if dir == 1:
		$AnimatedSprite2D.flip_h = false
	elif dir == -1:
		$AnimatedSprite2D.flip_h = true

	move_and_slide()

func _patrol() -> void:
	velocity.x = dir * patrol_speed

	
	if _turn_lock <= 0.0 and (wall_ray.is_colliding() or not ground_ray.is_colliding()):
		_turn()

	# If player is is sight , start chase
	if player != null:
		state = State.CHASE

func _chase() -> void:
	if player == null:
		state = State.PATROL
		return

	# Give up if too far 
	if global_position.distance_to(player.global_position) > leash_distance:
		player = null
		state = State.PATROL
		return

	# Move toward player
	var dx = player.global_position.x - global_position.x
	var adx = abs(dx)

	# Stop if close enough
	if adx <= stop_distance:
		velocity.x = 0
		return

	dir = 1 if dx > 0 else -1
	_apply_dir_to_rays()

	velocity.x = dir * chase_speed

	# Don’t chase off ledges
	if not ground_ray.is_colliding():
		_turn()

func _turn() -> void:
	dir *= -1
	_turn_lock = turn_cooldown
	_apply_dir_to_rays()

func _apply_dir_to_rays() -> void:
	ground_ray.target_position.x = abs(ground_ray.target_position.x) * dir
	wall_ray.target_position.x = abs(wall_ray.target_position.x) * dir

	# Optional: flip sprite if you want
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = (dir == 1)

func _on_vision_body_entered(body: Node) -> void:
	# Make sure your player is in player group 
	if body.is_in_group("player"):
		player = body as Node2D
		state = State.CHASE

func _on_vision_body_exited(body: Node) -> void:
	if body == player:
		player = null
		state = State.PATROL
