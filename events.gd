extends Node

# Parameter is new volume in Decibels.
signal volume_changed(volume_db: float)

signal target_changed(texture: ImageTexture)

signal target_reset()

signal bullet_fired

signal no_bullet_fired

## Each of the signals declared above can be connected by calling this method.
#func connect_signal(_signal: StringName, callable: Callable, flags: int = 0)\
#		-> Error:
#	return connect(_signal, callable, flags) 
