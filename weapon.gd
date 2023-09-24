extends Sprite2D

# Instanced to spawn a bullet.
const Bullet: PackedScene = preload("bullet.tscn")

# Timer for showing instructions when bullet has not been fired recently.
@onready var timer: Timer = $ShowInstructions

# Sound played when bullet is fired.
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound


func _ready() -> void:
	timer.process_callback = Timer.TIMER_PROCESS_IDLE
	timer.wait_time = 5.0 # seconds
	timer.one_shot = true
	timer.autostart = false
	timer.start()
	
	# The timeout signal indicates that no bullet was fired since the timer was
	# started. Emit the no_bullet_fired signal and restart the timer.
	timer.timeout.connect(func(): Events.no_bullet_fired.emit(); timer.start())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed\
		and get_rect().has_point(to_local(event.position)):
		fire_bullet()
	elif event is InputEventKey and event.pressed\
		and event.keycode == KEY_SPACE:
		fire_bullet()


func fire_bullet() -> void:

	# Emit the bullet_fired signal and restart the timer.	
	Events.bullet_fired.emit()
	timer.start()

	# Instantiate a bullet.
	var bullet: Area2D = Bullet.instantiate()
	
	# Add bullet to the scene.
	add_child(bullet)

	# Fire the bullet.
	bullet.fire(position)
	
	attack_sound.play()
