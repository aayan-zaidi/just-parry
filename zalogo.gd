extends CanvasItem 
var fadeDuration: float = 0.25

func _ready() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fadeDuration)
