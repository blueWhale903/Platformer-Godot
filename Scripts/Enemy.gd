extends "Entity.gd"




func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	
	move_and_slide(velocity)
