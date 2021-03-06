extends "Entity.gd"

var dead := false

onready var player := get_parent().get_node("Player")

func _ready() -> void:
	health = 2

func _physics_process(_dt: float) -> void:
#	var colliders = get_colliders()
#	for collider in colliders:
#		print(collider.name)
	if health <= 0:
		dead = true
		queue_free()
	
	if !dead:
		if is_on_floor():
			velocity.x = 0
		else:
			velocity.x = 0
		velocity = move_and_slide(velocity, Vector2.UP)


func _on_Area2D_area_entered(area: Area2D) -> void:
	health -= player.damage


func _on_Area2D_body_entered(body: Node) -> void:
	print(body.name)
