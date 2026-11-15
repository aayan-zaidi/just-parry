extends AnimatedSprite2D

@onready var heartSprites: Array[Sprite2D] = [
	$"../../HUD/Heart1",
	$"../../HUD/Heart2",
	$"../../HUD/Heart3"]
@onready var parry = $"../../Parry"
@onready var hit = $"../../Hit"
@onready var player = $"../../Player/AnimatedSprite2D"
@onready var scoreLabel = $"../../ScoreLabel"
@onready var getout = $"../../GETOUT"

var velX = 0.0
var velY = 0.0
const gameOberScreen = "./gameober.tscn"
var gravity = 900.0
var airTime = 1.0
var isParried = false
var hearts = 3
var isInvisible = false
var isWaiting = false
var spawnSide = 1
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	respawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hearts == 0:
		
		get_tree().change_scene_to_file(gameOberScreen)
		return
	if isWaiting:
		return
	#for i in range(hearts):
		#heartSprites[i].offset.y = sin(Time.get_ticks_msec() * 0.003 + i) * 3.0
	velY += gravity * delta
	global_position.x += velX * delta
	global_position.y += velY * delta

	if isParried:
		if global_position.y > 500.0:
			respawn()
	else:
		if global_position.y >= player.global_position.y:
			hearts -= 1
			
			if hearts >= 1:
				hit.play()
				create_tween().tween_callback(parry.stop).set_delay(1.0)

			
			var h = heartSprites[hearts]
			var t = create_tween().set_parallel(true)
			#t.tween_property(h, "scale", h.scale * 0.5, 0.1)
			#t.tween_property(h, "scale", Vector2.ZERO, 0.25)
			t.tween_property(h, "modulate:a", 0.0, 0.25)
			print(hearts)
			player.shakeStrength = 15.0
			player.modulate = Color(1.0, 0.661, 0.621, 1.0) # Flash player red
			create_tween().tween_property(player, "modulate", Color(1, 1, 1, 1), 0.25)
			isWaiting = true
			visible = false
			await get_tree().create_timer(0.15).timeout
			visible = true
			isWaiting = false
			respawn()

func respawn() -> void:  
	if isInvisible == true:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1, 0)	
	isParried = false
	play("default")
	var side = -1 if randf() > 0.5 else 1
	spawnSide = side 
	global_position.x = player.global_position.x + (side * 620.0)
	global_position.y = player.global_position.y - 320.0
	flip_h = (side == 1)
	velX = (player.global_position.x - global_position.x) / airTime
	velY = ((player.global_position.y - global_position.y) - 0.5 * gravity * airTime * airTime) / airTime
	

func getParried(dir: int) -> bool:
	if isParried or isWaiting or dir != spawnSide:
		return false
	var enemySide = sign(global_position.x - player.global_position.x)
	
	parry.play()
	create_tween().tween_callback(parry.stop).set_delay(1.0)

	isParried = true
	score += 100
	scoreLabel.text = str(score)
	
	scoreLabel.scale = Vector2(1.3, 1.3)
	create_tween().tween_property(scoreLabel, "scale", Vector2.ONE, 0.15)
	
	play("hurt")
	var fadeDuration: float = 0.5

	modulate.a = 0.5
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fadeDuration).set_delay(0.25)

	velX = dir * 900.0
	velY = -50.0
	airTime = max(0.5, airTime - 0.05)
	isInvisible = true
	return true
