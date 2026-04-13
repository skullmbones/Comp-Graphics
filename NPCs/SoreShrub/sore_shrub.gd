extends CharacterBody2D

@export var max_health: int = 2
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

	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()
	_check_attack_hits()

func _on_hurtbox_body_entered(body: Node) -> void:
	if dead:
		return

	if body.has_method("hit") and can_touch_damage:
		body.hit(touch_damage)
		_start_touch_cooldown()

func _check_attack_hits() -> void:
	var seen := {}

	for area in hurtbox.get_overlapping_areas():
		if area.is_in_group("player_attack") or area.name == "Hitbox":
			var id = area.get_instance_id()
			seen[id] = true

			if not counted_attack_areas.has(id):
				counted_attack_areas[id] = true
				take_damage(1)

	# remove attack areas that are no longer overlapping
	for id in counted_attack_areas.keys():
		if not seen.has(id):
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
