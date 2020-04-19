extends AnimatedSprite

export(int) var health
export(int) var speed
export(bool) var menu = false

var dead:bool = false

var walk_time: float = 0.7
var walk_timer: float = 0

var flicker_timer: float = 0

func _ready():
	play("idle")
	dead = false

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
				
	if flicker_timer > 0:
		modulate = Color(100,100,100)
		flicker_timer -= delta
	else: 
		modulate = Color(1,1,1)
		
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
