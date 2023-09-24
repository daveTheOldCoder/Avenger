extends AudioStreamPlayer2D

func _ready() -> void:
	Events.volume_changed.connect(func(v: float): volume_db = v)
