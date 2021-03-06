extends "Entity.gd"

# Nodes
onready var animator := get_node("AnimatedSprite")
onready var left_ray_cast := get_node("LeftRayCast")
onready var right_ray_cast := get_node("RightRayCast")
onready var attack_collision := get_node("AttackArea/AttackCollisionArea")
onready var tween := get_node("Tween")

# Time variables
var current_time := 0 # In seconds

# Movement variables
var direction : Vector2
var is_jump_interupted : bool
var is_jump_ready := false
var is_climb := false
export var speed := Vector2(400.0, 450.0)

# Attack variables
var attack_delay =  500 # In miliseconds
var next_attack_time = 0 # In miliseconds
var is_animating_attack := false

# Hurt status variables
var is_hurted := false
var is_hurted_animating := false
var boucing_back_velocity := Vector2(1500, -200)
var x_bounce_back_dir := 0

var dead := false


func _ready() -> void:
	health = 2

func _process(_dt: float) -> void:
	var _colliders = get_colliders()
		
	# Attack
	current_time = OS.get_system_time_msecs()
	if Input.is_action_just_pressed("attack") and current_time >= next_attack_time and !is_hurted:
		velocity.x = 0
		attack()
		next_attack_time = current_time + attack_delay
		is_animating_attack = true

	# Flipping attack area
	if animator.flip_h == true:
		get_node("AttackArea").scale.x = -1
	else:
		get_node("AttackArea").scale.x = 1

	animate()
	dead = is_dead()
	# Debug print()

func _physics_process(_dt: float) -> void:
	# print(OS.get_system_time_secs())
	# checking jumping was whether interuped or not
	if Input.is_action_just_released("ui_up") and velocity.y < 0.0:
		is_jump_interupted = true
	else:
		is_jump_interupted = false

	# Checking player is climbing or not
	is_climb = left_ray_cast.is_colliding() or right_ray_cast.is_colliding()
	# Checking conditions for jumping
	is_jump_ready = is_on_floor() or is_climb
	
	# Handling movement
	# Boucing out from enemy 
	if is_hurted:
		boucing_back_velocity.x *= x_bounce_back_dir
		velocity = move_and_slide(boucing_back_velocity, Vector2.UP)
		is_hurted = false
	# Cannot move when attack
	if !is_animating_attack and !dead:
		direction = get_direction()
		velocity = calculate_velocity(velocity, direction, is_jump_interupted)
		velocity = move_and_slide(velocity, Vector2.UP)
	
func get_direction() -> Vector2:
	var dir := Vector2.ZERO
	
	# X direction
	if Input.is_key_pressed(KEY_LEFT):
		animator.flip_h = true
		dir.x = -1
	elif Input.is_key_pressed(KEY_RIGHT):
		animator.flip_h = false
		dir.x = 1
	
	# Y direction
	if Input.is_action_pressed('ui_up') && is_on_floor():
		dir.y = -1
	elif Input.is_action_just_pressed('ui_up') and dir.x != 0 and is_climb:
		dir.y = -1
		dir.x *= -8
	
	else:
		dir.y = 0
		
	return dir
	
func calculate_velocity(prev_vel: Vector2, dir: Vector2, jump_interupted: bool) -> Vector2:
	var new_vel = prev_vel

	new_vel.x = dir.x * speed.x	 # Update x velocity

	# Update  velocity
	if dir.y != 0:
		new_vel.y = dir.y * speed.y
	if jump_interupted:
		new_vel.y = 0

	# Slow down y velocity when slide down on wall
	if (left_ray_cast.is_colliding() and dir.x < 0) or (right_ray_cast.is_colliding() and dir.x > 0):
		new_vel.y *= 0.78
	# Slow down x velocity when in mid-air
	if !is_on_floor():
		new_vel.x *= 0.6

	return new_vel

func attack():
	attack_collision.disabled = false

func is_dead() -> bool:
	if health <= 0:
		animator.play("dead")
		return true

	return false
func animate() -> void:
	if dead:
		animator.play("dead")
	elif is_hurted_animating:
		animator.play("hurt")
	# Attack animation
	elif is_animating_attack:
		animator.play("air_attack")
	# Movement animation
	elif direction.x != 0 and is_on_floor():
		animator.play("walk")
	elif velocity.y > 0 and is_climb and !is_on_floor():
		animator.play("wall_slide")
	elif velocity.y > 0 and !is_on_floor() :
		animator.play("fall")
	elif velocity.y < 0:
		animator.play("jump")
	else:
		animator.play("idle")

func _on_AnimatedSprite_animation_finished() -> void:
	if animator.animation == "hurt":
		set_collision_layer_bit(1, true)
		set_collision_mask_bit(2, true)
		$HitArea.set_collision_mask_bit(2, true)
		is_hurted_animating = false
		
	if animator.animation == "air_attack":
		is_animating_attack = false
		attack_collision.disabled = true

	if animator.animation == "dead":
		queue_free()
		
func _on_HitArea_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		health -= body.damage
		if !dead:
			is_hurted = true
			is_hurted_animating = true
			
			$AnimationPlayer.play("hurt")
			$HitArea.set_collision_mask_bit(2, false)
			set_collision_layer_bit(1, false)
			set_collision_mask_bit(2, false)
			
			x_bounce_back_dir = -1 if body.position.x > position.x else 1

