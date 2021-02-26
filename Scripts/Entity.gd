extends KinematicBody2D

export var gravity := 980.0

var velocity := Vector2.ZERO

func _physics_process(dt: float) -> void:
	velocity.y += gravity * dt
