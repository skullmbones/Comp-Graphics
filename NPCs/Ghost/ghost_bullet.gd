extends Area2D

var speed = 300
var direction = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit(2)
		
	speed = 0
	$AnimatedSprite2D.scale = Vector2(0.25, 0.25)
	$AnimatedSprite2D.play("hit")

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		queue_free()
