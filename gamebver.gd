extends Control

const gameScene = "./main.tscn"
var isTransitioning = false

@onready var getout = $"./GETOUT"

func _ready() -> void:
	getout.play()
	create_tween().tween_callback(getout.stop).set_delay(5.0)

func _unhandled_input(event: InputEvent) -> void:
		
		if event.is_action_pressed("ui_accept"):		
			isTransitioning = true
		
			var fade_rect = ColorRect.new()
			fade_rect.color = Color(0, 0, 0, 0) 
			fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			add_child(fade_rect)
			
			var tween = create_tween()
			tween.tween_property(fade_rect, "color:a", 1.0, 0.25)
			await tween.finished
			
			get_tree().change_scene_to_file(gameScene)
