extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hitstop(timeScale: float, duration: float) -> void:
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration, true, false, true).timeout
	
	Engine.time_scale = 1.0
