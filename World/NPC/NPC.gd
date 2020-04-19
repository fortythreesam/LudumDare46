extends AnimatedSprite

export(float) var speed
export(int) var health = 3

var dead:bool = false

var full_heart = preload("res://World/UI/Healthbar/Heart_0.png")
var empty_heart = preload("res://World/UI/Healthbar/Heart_1.png")

var walk_time: float = 0.7
var walk_timer: float = 0
var healing_timer: float = 30
const head_center = Vector2(0, -17)
var game_over:bool = false

var flicker_timer: float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	play("walk")
	game_over = false

func _process(delta):
	if not dead and not game_over:
		position += Vector2(-1, 0) * speed * delta
		if healing_timer <= 0:
			health = min(3, health + 1)
			$Heal.play()
			healing_timer = 30
		elif health < 3 :
			healing_timer -= delta
		else:
			healing_timer = 30
	else:
		play("idle")
	
	if flicker_timer > 0:
		modulate = Color(100,100,100)
		flicker_timer -= delta
	else: 
		modulate = Color(1,1,1)
		
	update()
	
func _draw():
	for i in range(3):
		if i <= health -1:
			draw_texture(full_heart, head_center + Vector2(-4 + (2 * i), 0))
		else:
			draw_texture(empty_heart, head_center + Vector2(-4 + (2 * i), 0))


func _on_Hurtbox_area_entered(area):
	if not dead:
		if area.get_name() == 'Hitbox':
			$Hit.play()
			health -= 1
			flicker_timer = 0.1
			if health <= 0:
				dead = true
				play("dying")
				$Particles2D.emitting = false


func _on_NPC_animation_finished():
	if animation == "dying":
		play("dead")
