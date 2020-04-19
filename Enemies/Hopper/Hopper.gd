extends AnimatedSprite

export(float) var walk_speed = 25
export(float) var jump_speed = 60
export(float) var attack_cooldown = 10


var target:Vector2
var move_direction:Vector2
var target_direction: Vector2
var cooldown_timer:float
var reaction_time:float
var reaction_timer:float = 0;
var reacting: bool = false
var kill: bool = false
var flicker_timer: float = 0;

func _ready():
	remove_target()
	play("idle")
	cooldown_timer = 0
	reaction_time = rand_range(0.1,0.6)
	reacting = true
	kill = false

func _process(delta):
	if not kill:
		if target != null:
			if not ['attack'].has(animation):
				var target_direction = Vector2(sign(floor(target.x - position.x)), sign(floor(target.y - position.y)))
				if target_direction != move_direction and not reacting:
					reaction_timer = reaction_time
					reacting = true
				else:
					if reaction_timer <= 0:
						move_direction = Vector2(sign(floor(target.x - position.x)), sign(floor(target.y - position.y)))
						reacting = false
				if position.distance_to(target) < 50 and cooldown_timer <= 0:
					print("test")
					play("attack_start")
					cooldown_timer = attack_cooldown
				elif not ['walk', 'attack_start'].has(animation):
					play('walk')	
				position += move_direction.normalized() * walk_speed * delta
			else:
				position += move_direction.normalized() * jump_speed * delta
			if move_direction.x > 0:
				flip_h = false
			elif move_direction.x < 0:
				flip_h = true
		if cooldown_timer >= 0:
			cooldown_timer -= delta
		if reaction_timer > 0:
			reaction_timer -= delta
			
	if flicker_timer > 0:
		modulate = Color(100,100,100)
		flicker_timer -= delta
	else: 
		modulate = Color(1,1,1)
		


func set_target(new_target:Vector2):
	target = new_target

func remove_target():
	target = position

func _on_Hopper_animation_finished():
	match animation:
		"attack_start":
			move_direction = Vector2(target.x - position.x, target.y - position.y)
			$Hitbox/CollisionShape2D.set_deferred("disabled", false)
			play("attack")
		"attack":
			$Hitbox/CollisionShape2D.set_deferred("disabled", false)
			play("idle")
			


func _on_Hurtbox_area_entered(area):
	if area.get_name() == "Hitbox":
		flicker_timer = 0.1
		kill = true
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
		play("dead")
