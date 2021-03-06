extends KinematicBody2D

export var gravity := 980.0
export var health := 5
export var damage := 1

var velocity := Vector2.ZERO

func _physics_process(dt: float) -> void:
	velocity.y += gravity * dt

func get_colliders() -> Array:
	var colliders := []
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		colliders.push_back(collision.collider)
	
	return colliders
	
