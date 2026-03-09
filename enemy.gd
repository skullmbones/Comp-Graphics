extends CharacterBody2D

var health = 75

enum State { PATROL, CHASE, ATTACK, RETURN }
var state: State = State.PATROL

@export var gravity := 1200.0

# Patrol
@export var patrol_speed := 60.0
@export var patrol_radius := 80.0
@export var patrol_pause := 0.15

# Chase
@export var chase_speed := 80.0
@export var stop_distance := 18.0

# Return
@export var return_speed := 140.0
@export var turn_cooldown := 0.12

# Attack
@export var attack_range_x := 55.0
@export var attack_range_y := 35.0
@export var attack_frame := 23

var dir := 1
var _turn_lock := 0.0
var _pause_timer := 0.0
var attack_applied := false

var player: Node2D = null
var spawn_x := 0.0

@onready var ground_ray: RayCast2D = $ground
@onready var wall_ray: RayCast2D = $wall
@onready var vision: Area2D = $vision
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	spawn_x = global_position.x
	_apply_dir_to_rays()

	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)

	anim.frame_changed.connect(_on_enemy_frame_changed)
	anim.animation_finished.connect(_on_enemy_animation_finished)


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
		State.ATTACK:
			_attack()
		State.RETURN:
			_return_to_patrol()

	move_and_slide()


func _patrol() -> void:
	_play_anim("walk")

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

	dir = 1 if dx > 0 else -1
	_apply_dir_to_rays()

	if _player_in_attack_window():
		_start_attack()
		return

	_play_anim("walk")
	velocity.x = dir * chase_speed

	if not ground_ray.is_colliding():
		_turn()


func _attack() -> void:
	velocity.x = 0
	_play_anim("kill")


func _return_to_patrol() -> void:
	_play_anim("walk")

	var left_edge = spawn_x - patrol_radius
	var right_edge = spawn_x + patrol_radius

	# If back in patrol zone, resume patrol
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


func _start_attack() -> void:
	if state == State.ATTACK:
		return

	state = State.ATTACK
	velocity.x = 0
	attack_applied = false
	anim.play("kill")


func _player_in_attack_window() -> bool:
	if player == null:
		return false

	var dx = player.global_position.x - global_position.x
	var dy = abs(player.global_position.y - global_position.y)

	var in_front = dx * dir >= 0
	var close_enough = abs(dx) <= attack_range_x and dy <= attack_range_y
	return in_front and close_enough


func _kill_player() -> void:
	if player and player.has_method("hit"):
		player.hit(100)


func _on_enemy_frame_changed() -> void:
	if anim.animation == "kill" and anim.frame == attack_frame and not attack_applied:
		attack_applied = true

		if _player_in_attack_window():
			_kill_player()


func _on_enemy_animation_finished() -> void:
	if anim.animation == "kill":
		attack_applied = false

		if player != null:
			state = State.CHASE
		else:
			state = State.RETURN


func _turn() -> void:
	dir *= -1
	_turn_lock = turn_cooldown
	_apply_dir_to_rays()


func _apply_dir_to_rays() -> void:
	ground_ray.target_position.x = abs(ground_ray.target_position.x) * dir
	wall_ray.target_position.x = abs(wall_ray.target_position.x) * dir

	$AnimatedSprite2D.flip_h = (dir == -1)

func _play_anim(name: String) -> void:
	if anim.animation != name:
		anim.play(name)


func _on_vision_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body as Node2D

		if state != State.ATTACK:
			state = State.CHASE


func _on_vision_body_exited(body: Node) -> void:
	if body == player:
		player = null

		if state != State.ATTACK:
			state = State.RETURN


func take_damage(amount) -> void:
	health -= amount
	print(health)

	if health <= 0:
		queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		take_damage(25)
