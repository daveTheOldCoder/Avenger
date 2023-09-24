extends Area2D

# Bullet's speed (pixels / second).
const SPEED: int = 800

# Bullet's velocity.
var velocity: Vector2


func _ready():
	
	hide()

	# No movement until bullet is fired.
	set_physics_process(false)

	body_entered.connect(_on_body_entered)

	$VisibleOnScreenNotifier2D.screen_exited.connect(func(): queue_free())

	# Bullet's direction of travel.
	var direction: Vector2 = Vector2.UP
	
	# Orient bullet toward its direction of travel.
	# This assumes that bullet shape is oriented toward positive x-axis.
	rotation = direction.angle()

	# Bullet's velocity.
	velocity = direction * float(SPEED)
	

func _physics_process(delta: float) -> void:
	# Move bullet.
	global_translate(velocity * delta)


func _on_body_entered(body: CollisionObject2D) -> void:
	if body.has_method("bullet_hit"):
		body.bullet_hit()
	queue_free()


# Fire bullet.
# Parameter is initial position of bullet in global coordinates.
func fire(initial_position: Vector2) -> void:

	position = to_local(initial_position)

	# Start movement.
	set_physics_process(true)
	
	show()
