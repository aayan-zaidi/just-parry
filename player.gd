extends AnimatedSprite2D

@onready var camera = $"../../Camera2D"
var shakeStrength = 0.0
var sparkTimer = 0.0
var sparkDirs = [Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0.5, -1.5), Vector2(0.5, 1.5)]

@onready var enemy = $"../../Enemy/AnimatedSprite2D"
var parryWindow = 0.1
var parryTimer = 0.0
var whiffTimer = 0.0
var direction = 1
@onready var baseScaleX = abs(scale.x)
var isSwinging = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shakeStrength > 0:
		camera.offset = Vector2(randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength))
		shakeStrength = lerp(shakeStrength, 0.0, 22.0 * delta)
	else:
		camera.offset = Vector2.ZERO

	camera.zoom = camera.zoom.lerp(Vector2(1.0, 1.0), 18.0 * delta)

	if sparkTimer > 0:
		sparkTimer -= delta
		queue_redraw()

	if parryTimer > 0:
		parryTimer -= delta 
		checkParry()
	if whiffTimer > 0:
		whiffTimer -= delta
		return
	if isSwinging:
			return
	if Input.is_action_just_pressed("ui_left"):
		swing(-1)
	elif Input.is_action_just_pressed("ui_right"):
		swing(1)
	pass

func swing(dir) -> void:
	direction = dir
	isSwinging = true
	parryTimer = parryWindow
		
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0.1, 0.04)
	tween.tween_callback(func(): flip_h = (dir == -1))
	tween.tween_property(self, "scale:x", baseScaleX, 0.04)
		
	play("attack")
	await animation_finished
	play("default")
	isSwinging = false
		
	
func checkParry() -> void:
	if enemy.isParried:
		return
	
	var psize = sprite_frames.get_frame_texture(animation, frame).get_size() * abs(scale.y) * 0.3
	var esize = enemy.sprite_frames.get_frame_texture(enemy.animation, enemy.frame).get_size() * abs(enemy.scale) * 0.3
	
	
	var dx = enemy.global_position.x - global_position.x
	var dy = abs(enemy.global_position.y - global_position.y)
	
	var touchingX = abs(dx) <= (psize.x + esize.x)
	var touchingY = dy <= (psize.y + esize.y)
	var facingEnemy = (direction == enemy.spawnSide)

	if facingEnemy and touchingX and touchingY:
		if enemy.getParried(direction):
			parryTimer = 0.0
			whiffTimer = 0.0
			enemy.getParried(direction)
			sparkTimer = 0.14
			shakeStrength = 30.0
			camera.zoom = Vector2(1.06, 1.06)
			modulate = Color(5, 5, 5, 1)
			enemy.modulate = Color(5, 5, 5, 0.5)
			await GameManager.hitstop(0.02, 0.075)
			modulate = Color(1, 1, 1, 1)
			enemy.modulate = Color(1, 1, 1, 1)
		else:
			whiffTimer = 0.3
	
func _draw() -> void:
	if sparkTimer > 0:
		var progress = 1.0 - (sparkTimer / 0.14)
		for dir_vec in sparkDirs:
			var pos = Vector2(direction * 25.0, 0) + Vector2(dir_vec.x * direction, dir_vec.y) * (progress * 70.0)
			draw_rect(Rect2(pos.round(), Vector2(4, 4)), Color.WHITE)
