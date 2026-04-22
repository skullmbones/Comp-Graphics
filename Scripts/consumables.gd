extends Area2D

@export var heal_amount: int = 40
@export var destroy_on_use: bool = true

# Optional:
# If your player is in a group called "player", turn this on.
@export var require_player_group: bool = false
@export var player_group_name: String = "player"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == null:
		return

	# Optional player-only check
	if require_player_group and not body.is_in_group(player_group_name):
		return

	# Make sure the body actually has health and max_health variables
	if not _has_property(body, "health") or not _has_property(body, "max_health"):
		return

	# Heal, but never go above max_health
	body.health = clamp(body.health + heal_amount, 0, body.max_health)

	# Remove the consumable after use
	if destroy_on_use:
		queue_free()

func _has_property(node: Object, property_name: String) -> bool:
	for prop in node.get_property_list():
		if prop.name == property_name:
			return true
	return false
