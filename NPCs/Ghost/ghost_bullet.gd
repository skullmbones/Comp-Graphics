extends Area2D

@export var speed := 180.0
@export var damage := 1

var direction := Vector2.ZERO
var hitbox: Area2D = null


func _ready() -> void:
	hitbox = _find_area2d_child()

	if hitbox != null:
		hitbox.monitoring = true
		hitbox.monitorable = true

		if not hitbox.body_entered.is_connected(_on_body_entered):
			hitbox.body_entered.connect(_on_body_entered)

		if not hitbox.area_entered.is_connected(_on_area_entered):
			hitbox.area_entered.connect(_on_area_entered)
	else:
		print("WARNING: GhostBullet has no Area2D child for collision.")

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play()

	if has_node("Sprite2D"):
		$Sprite2D.visible = true

	print("Ghost bullet ready at: ", global_position, " direction: ", direction)


func _find_area2d_child() -> Area2D:
	for child in get_children():
		if child is Area2D:
			return child

	return null


func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return

	global_position += direction.normalized() * speed * delta


func _on_body_entered(body: Node2D) -> void:
	print("Ghost bullet body hit: ", body.name, " Groups: ", body.get_groups())

	if body.is_in_group("player"):
		if body.has_method("hit"):
			body.hit(damage)

		queue_free()
		return

	if body.name == "Level Collisions":
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	print("Ghost bullet area hit: ", area.name, " Groups: ", area.get_groups())

	var parent = area.get_parent()

	if area.is_in_group("player"):
		if area.has_method("hit"):
			area.hit(damage)
		elif parent != null and parent.has_method("hit"):
			parent.hit(damage)

		queue_free()
		return

	if parent != null and parent.is_in_group("player"):
		if parent.has_method("hit"):
			parent.hit(damage)

		queue_free()
		return
