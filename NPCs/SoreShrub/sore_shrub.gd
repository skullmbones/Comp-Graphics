extends CharacterBody2D

@export var max_health: int = 50
@export var attack_damage: int = 25
@export var touch_damage: int = 15
@export var touch_cooldown: float = 0.5
@export var gravity: float = 1200.0

var health: int
var dead := false
var can_touch_damage := true
var counted_attack_areas := {}

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	health = max_health

	hurtbox.monitoring = true
	hurtbox.monitorable = true

func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	velocity = Vector2.ZERO
	move_and_slide()

	_check_overlaps()

func _check_overlaps() -> void:
	var seen_attack_ids := {}

	for area in hurtbox.get_overlapping_areas():
		if area == null:
			continue

		# Player weapon hitbox damages shrub
		if area.is_in_group("player_attack") or area.name == "Hitbox":
			var id = area.get_instance_id()
			seen_attack_ids[id] = true

			if not counted_attack_areas.has(id):
				counted_attack_areas[id] = true
				take_damage(attack_damage)

		# Player hurtbox gets damaged by shrub
		elif area.is_in_group("player_hurtbox") or area.name == "Hurtbox":
			var player = area.get_parent()

			if can_touch_damage and player != null and player.is_in_group("player"):
				if player.has_method("hit"):
					player.hit(touch_damage)
					_start_touch_cooldown()

	for id in counted_attack_areas.keys().duplicate():
		if not seen_attack_ids.has(id):
			counted_attack_areas.erase(id)

func take_damage(amount: int) -> void:
	if dead:
		return

	health -= amount

	sprite.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout

	if is_instance_valid(sprite):
		sprite.modulate = Color(1, 1, 1)

	if health <= 0:
		die()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO

	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

	queue_free()

func _start_touch_cooldown() -> void:
	can_touch_damage = false
	await get_tree().create_timer(touch_cooldown).timeout
	can_touch_damage = true
