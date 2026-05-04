extends Area2D

@export var heal_amount: int = 4
@export var destroy_on_use: bool = true

# If your player is in a group called "player", leave this on.
@export var require_player_group: bool = true
@export var player_group_name: String = "player"

var can_pickup := false


func _ready() -> void:
	visible = true
	z_index = 100

	monitoring = false
	monitorable = true

	if has_node("Sprite2D"):
		$Sprite2D.visible = true
		$Sprite2D.z_index = 100

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	print("Consumable spawned at: ", global_position)

	# Prevent instant pickup on the same frame it drops.
	await get_tree().create_timer(0.35).timeout

	can_pickup = true
	monitoring = true
	print("Consumable can now be picked up.")


func _on_body_entered(body: Node) -> void:
	if not can_pickup:
		return

	if body == null:
		return

	if require_player_group and not body.is_in_group(player_group_name):
		return

	if not _has_property(body, "health") or not _has_property(body, "max_health"):
		print("Consumable touched something without health/max_health: ", body.name)
		return

	body.health = clamp(body.health + heal_amount, 0, body.max_health)
	print("Consumable healed player to: ", body.health)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_hp"):
		hud.update_hp(body.health)
	
	if destroy_on_use:
		call_deferred("queue_free")


func _has_property(node: Object, property_name: String) -> bool:
	for prop in node.get_property_list():
		if prop.name == property_name:
			return true

	return false
