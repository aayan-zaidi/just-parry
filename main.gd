extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var layer = CanvasLayer.new()	
	layer.layer = 100 
	
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(layer)
	layer.add_child(fade)
	
	create_tween().tween_property(fade, "color:a", 0.0, 0.25).finished.connect(layer.queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
