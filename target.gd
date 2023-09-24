extends CharacterBody2D

const SPEED: float = 500.0

@onready var left_limit: Vector2 = $LeftLimit.position
@onready var right_limit: Vector2 = $RightLimit.position

@onready var hit_sound: AudioStreamPlayer2D = $HitSound

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	position = left_limit
	velocity = Vector2(SPEED, 0.0)
	
	Events.target_changed.connect(func(t: ImageTexture): sprite.texture = t)

	show()


func _physics_process(delta: float) -> void:
	# Move back and forth between left_limit and right_limit.

	# Reverse direction when a limit is reached.
	if (velocity.x >= 0.0 and position.x >= right_limit.x)\
			or (velocity.x < 0.0 and position.x <= left_limit.x):
		velocity.x = -velocity.x

	# Move.
	position += velocity * delta


# Called when this node is hit by a bullet.
func bullet_hit() -> void:
	hit_sound.play()
	spin()


# Perform visual effect.
func spin() -> void:

	# Multiplier for spin direction.
	# Randomly choose 1.0 (clockwise) or -1.0 (counterclockwise). 
	var mult: float = [1.0, -1.0][randi() % 2]
	
	# Interpolate rotation from 0.0 to mult * 4.0 * PI (two 360-degree
	# rotations) over 0.5 second.
	var spin_tween: Tween = create_tween()
	spin_tween.tween_property(self, "rotation", mult * 4.0 * PI, 0.5).from(0.0)
