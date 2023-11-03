extends CharacterBody2D

const SPEED: float = 500.0

const SAVE_PATH: String = "user://image.dat"

@onready var left_limit: Vector2 = $LeftLimit.position
@onready var right_limit: Vector2 = $RightLimit.position

@onready var hit_sound: AudioStreamPlayer2D = $HitSound

# Default target image.
# This is needed for resetting target image to the default.
@onready var default_sprite: Sprite2D = $DefaultSprite

# Currently displayed target image.
# This can be changed by the user.
@onready var current_sprite: Sprite2D = $CurrentSprite

@onready var file_dialog: FileDialog = %FileDialog
@onready var url_dialog: Panel = %UrlDialog
@onready var upload_dialog: Panel = %UploadDialog


func _ready() -> void:
	position = left_limit
	velocity = Vector2(SPEED, 0.0)
	
	Events.target_changed.connect(_on_target_changed)

	Events.target_reset.connect(_on_target_reset)

	current_sprite.texture = default_sprite.texture

	load_target_image()
	
	current_sprite.show()
	default_sprite.hide()
	
	show()


func _process(_delta) -> void:
	set_physics_process(not (file_dialog.visible or url_dialog.visible\
		or upload_dialog.visible))


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


func _on_target_changed(t: ImageTexture) -> void:
	current_sprite.texture = t
	current_sprite.texture.get_image().save_webp(SAVE_PATH)


func _on_target_reset() -> void:
	current_sprite.texture = default_sprite.texture
	# Save the default image, in case DirAccess.remove_absolute() fails.
	current_sprite.texture.get_image().save_webp(SAVE_PATH)
	DirAccess.remove_absolute(SAVE_PATH)


func load_target_image() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		#print_debug("'%s' does not exist" % SAVE_PATH)
		return

	var err: Error
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	err = OK if file != null else FileAccess.get_open_error()
	if err != OK:
		print_debug("Failed to open '%s' for reading: %d (%s)"\
				% [SAVE_PATH, err, error_string(err)])
		return

	var data: PackedByteArray = file.get_buffer(file.get_length())
	var image: Image = Image.new()
	err = image.load_webp_from_buffer(data)
	if err != OK:
		print_debug("Failed to load image: %d (%s)" % [err, error_string(err)])
		return

	current_sprite.texture = ImageTexture.create_from_image(image)
