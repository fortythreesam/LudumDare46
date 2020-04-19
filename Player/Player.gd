extends AnimatedSprite


var move_direction:Vector2
export(float) var default_speed
export(float) var max_health
var health: float
var speed: float
var dead: bool = false
signal health_updated(new_health)
signal new_max_health(new_health)
var last_direction_moved:Vector2
var walk_time: float = 0.5
var walk_timer: float = 0

var flicker_timer: float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	speed = default_speed
	health = max_health
	dead = false
	walk_timer = walk_time
	last_direction_moved = Vector2(1,0)
	emit_signal("new_max_health", max_health)
	emit_signal("health_updated", health)

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		if not ["attack_start", "attack", "slide", "ghost_idle", "ghost_walk"].has(animation):
			play("attack_start")
	if Input.is_action_just_pressed("slide"):
		if not ["attack", "slide", "slide_start", "slide_end", "ghost_idle", "ghost_walk"].has(animation):
			play("slide_start")

	move_direction = Vector2(0,0)
	if not["slide"].has(animation):
		if Input.is_action_pressed("move_left"):
			move_direction.x -= 1
		if Input.is_action_pressed("move_right"):
			move_direction.x += 1
		if Input.is_action_pressed("move_up"):
			move_direction.y -= 1
		if Input.is_action_pressed("move_down"):
			move_direction.y += 1
		if move_direction.x == 0 and move_direction.y == 0:
			if playing == false or animation == "walking":
				set_idle()
		elif animation == "idle": 
			if (move_direction.x > 0 and not flip_h) or (move_direction.x < 0 and flip_h) or (move_direction.y > 0 and flip_h) or (move_direction.y < 0 and not flip_h):
				if not dead:
					play("walking")
				else:
					play("ghost_walking")
			elif (move_direction.x > 0 and  flip_h) or (move_direction.x < 0 and not flip_h) or (move_direction.y > 0 and not flip_h) or (move_direction.y < 0 and flip_h):
				play("walking", true)
				if not dead:
					play("walking", true)
				else:
					play("ghost_walking", true)
		if get_global_mouse_position().x - position.x > 0:
			flip_h = false
			$Hurtbox/CollisionShape2D.position.x = -0.5
			$Hitbox/CollisionShape2D.position.x = 10.5
		elif get_global_mouse_position().x - position.x < 0:
			flip_h = true
			$Hurtbox/CollisionShape2D.position.x = 1.5
			$Hitbox/CollisionShape2D.position.x = -9.5
	else:
		move_direction = last_direction_moved
		if move_direction.x > 0:
			flip_h = false
		if move_direction.x < 0:
			flip_h = true
	position += move_direction.normalized() * speed * delta
	if abs(move_direction.x) + abs(move_direction.y) > 0:
		last_direction_moved = move_direction
	
	if abs(move_direction.x + move_direction.y) > 0 and animation != "slide":
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
		
	


func _on_Player_animation_finished():
	match animation:
		"attack_start":
			speed *= 0.65
			$Hitbox/CollisionShape2D.set_deferred("disabled", false)
			$Attack.play()
			animation = "attack"
		"attack":
			speed = default_speed
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			set_idle()
		"slide_start":
			speed *= 4
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			animation = "slide"
		"slide":
			speed = default_speed
			$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
			animation = "slide_end"
		"slide_end":
			set_idle()
		"walking":
			play("walking")
		_:
			set_idle()

func set_idle():
	if not dead:
		play("idle")
	else:
		play("ghost_idle")

func _on_Hurtbox_area_entered(area):
	if area.get_name() == 'Hitbox':
		if not dead:
			$Hit.play()
			health -= 1
			flicker_timer = 0.1
			if health <= 0:
				dead = true
				play("ghost_idle")
				$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
				$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			emit_signal("health_updated", health)
