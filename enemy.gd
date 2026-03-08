extends CharacterBody2D

var health = 75
enum State { PATROL, CHASE, RETURN }
var state: State = State.PATROL

@export var gravity := 1200.0

# Patrol 
@export var patrol_speed := 60.0
@export var patrol_radius := 80.0
@export var patrol_pause := 0.15

# Chase 
@export var chase_speed := 80.0
@export var stop_distance := 18.0


@export var return_speed := 140.0
@export var turn_cooldown := 0.12

var dir := -1
var _turn_lock := 0.0

var player: Node2D = null
var spawn_x := 0.0

var _pause_timer := 0.0

@onready var ground_ray: RayCast2D = $ground
@onready var wall_ray: RayCast2D = $wall
@onready var vision: Area2D = $vision


func _ready() -> void:
	spawn_x = global_position.x
	_apply_dir_to_rays()

	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)


func _physics_process(delta: float) -> void:

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	_turn_lock = max(0.0, _turn_lock - delta)
	_pause_timer = max(0.0, _pause_timer - delta)

	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()
		State.RETURN:
			_return_to_patrol()

	move_and_slide()


func _patrol() -> void:

	if _pause_timer > 0:
		velocity.x = 0
		return

	var left_edge = spawn_x - patrol_radius
	var right_edge = spawn_x + patrol_radius

	if global_position.x <= left_edge:
		dir = 1
		_pause_timer = patrol_pause
		_apply_dir_to_rays()

	elif global_position.x >= right_edge:
		dir = -1
		_pause_timer = patrol_pause
		_apply_dir_to_rays()

	velocity.x = dir * patrol_speed

	if _turn_lock <= 0.0 and (wall_ray.is_colliding() or not ground_ray.is_colliding()):
		_turn()

	if player != null:
		state = State.CHASE
		
func _chase() -> void:

	if player == null:
		state = State.RETURN
		return

	var dx = player.global_position.x - global_position.x
	var adx = abs(dx)

	if adx <= stop_distance:
		velocity.x = 0
		return

	dir = 1 if dx > 0 else -1
	_apply_dir_to_rays()

	velocity.x = dir * chase_speed

	if not ground_ray.is_colliding():
		_turn()


func _return_to_patrol() -> void:

	var left_edge = spawn_x - patrol_radius
	var right_edge = spawn_x + patrol_radius

	# If we are back in patrol zone, resume patrol
	if global_position.x >= left_edge and global_position.x <= right_edge:
		state = State.PATROL
		return

	# Move quickly toward patrol area
	if global_position.x < left_edge:
		dir = 1
	elif global_position.x > right_edge:
		dir = -1

	_apply_dir_to_rays()

	velocity.x = dir * return_speed

	if _turn_lock <= 0.0 and (wall_ray.is_colliding() or not ground_ray.is_colliding()):
		_turn()


func _turn() -> void:
	dir *= -1
	_turn_lock = turn_cooldown
	_apply_dir_to_rays()


func _apply_dir_to_rays() -> void:

	ground_ray.target_position.x = abs(ground_ray.target_position.x) * dir
	wall_ray.target_position.x = abs(wall_ray.target_position.x) * dir

	if has_node("Sprite2D"):
		$Sprite2D.flip_h = (dir == 1)


func _on_vision_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body as Node2D
		state = State.CHASE


func _on_vision_body_exited(body: Node) -> void:
	if body == player:
		player = null
		state = State.RETURN
		
func take_damage(amount) -> void:
	health -= amount
	print(health)
	if health <= 0:
		queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		take_damage(25)
