extends AnimatedSprite

export(int) var speed
export(bool) var menu = false

var dead:bool = false
var health

var full_heart = preload("res://World/UI/Healthbar/Heart_0.png")
var empty_heart = preload("res://World/UI/Healthbar/Heart_1.png")

var walk_time: float = 0.7
var walk_timer: float = 0
var healing_timer: float = 30

var flicker_timer: float = 0

const head_center = Vector2(0, -7)

func _ready():
	play("idle")
	dead = false
	healing_timer = 30
	health = 3

func _process(delta):
	if not dead:
		if not menu:
			position += Vector2(-1,0) * speed * delta
			if animation != "walk":
				play("walk")

		if animation == "walk":
			if walk_timer <= 0:
				walk_timer = walk_time
				$Step.play()
			else:
				walk_timer -= delta
		if healing_timer <= 0:
			health = min(3, health + 1)
			$Heal.play()
			healing_timer = 30
		elif health < 3 :
			healing_timer -= delta
		else:
			healing_timer = 30
				
	if flicker_timer > 0:
		modulate = Color(100,100,100)
		flicker_timer -= delta
	else: 
		modulate = Color(1,1,1)
	
	update()
	
func _draw():
	if not menu:
		for i in range(3):
			if i <= health -1:
				draw_texture(full_heart, head_center + Vector2(-2 + (2 * i), 0))
			else:
				draw_texture(empty_heart, head_center + Vector2(-2 + (2 * i), 0))
		
func _on_Hurtbox_area_entered(area):
	if not dead:
		if area.get_name() == "Hitbox":
			$Hit.play()
			health -= 1
			flicker_timer = 0.1
			if health <= 0:
				play("dying")
				dead = true
				$Hurtbox/CollisionShape2D.set_deferred("disabled", true)


func _on_It_animation_finished():
	match animation:
		"dying":
			play("dead")
