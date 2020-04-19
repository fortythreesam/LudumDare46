extends AnimatedSprite


var move_direction:Vector2
export(float) var default_speed
export(float) var max_health
export(float) var attack_time
var attack_timer:float
var health: float
var speed: float
var dead: bool = false
signal health_updated(new_health)
signal new_max_health(new_health)
var last_direction_moved:Vector2
var walk_time: float = 0.5
var walk_timer: float = 0
var healer_location: Vector2
var healing_timer: float = 10
const head_center = Vector2(0, -16)
var score: float = 0
var game_over:bool = false

var knockback_direction: Vector2
var knockback: float

var full_heart = preload("res://World/UI/Healthbar/Heart_0.png")
var empty_heart = preload("res://World/UI/Healthbar/Heart_1.png")

var slowdown_timer: float = 0

var flicker_timer: float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	speed = default_speed
	health = max_health
	dead = false
	playing = true
	game_over = false
	knockback = 0
	knockback_direction = Vector2(0,0)
	walk_timer = walk_time
	attack_timer = 0
	score = 0
	last_direction_moved = Vector2(1,0)
	emit_signal("new_max_health", max_health)
	emit_signal("health_updated", health)

func _process(delta):
	if not game_over:
		score += delta
	$DirectionLine.points[0] = Vector2(0,0)
	$DirectionLine.points[1] = (get_global_mouse_position() - position) + Vector2(4.5, 4.5)
	
	
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
			if ["walking", "ghost_walk"].has(animation):
				set_idle()
		elif animation == "idle" or animation == "ghost_idle": 
			if (move_direction.x > 0 and not flip_h) or (move_direction.x < 0 and flip_h) or (move_direction.y > 0 and flip_h) or (move_direction.y < 0 and not flip_h):
				if not dead:
					play("walking")
				else:
					play("ghost_walk")
			elif (move_direction.x > 0 and  flip_h) or (move_direction.x < 0 and not flip_h) or (move_direction.y > 0 and not flip_h) or (move_direction.y < 0 and flip_h):
				if not dead:
					play("walking", true)
				else:
					play("ghost_walk", true)
		if get_global_mouse_position().x - position.x > 0:
			flip_h = false
			$Hurtbox.scale.x = -1
			$Hitbox.scale.x = -1
		elif get_global_mouse_position().x - position.x < 0:
			flip_h = true
			$Hurtbox.scale.x = 1
			$Hitbox.scale.x = 1
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
		
	if slowdown_timer >= 0:
		slowdown_timer -= delta
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1
		
	if abs(position.distance_to(healer_location)) < 80:
		if health < max_health:
			healing_timer -= delta
			if healing_timer <= 0:
				health += 1
				healing_timer = 10
				$Heal.play()
		else:
			healing_timer = 10
	else:
			healing_timer = 10
			
	if animation == "attack":
		attack_timer -= delta
		if attack_timer <= 0:
			speed = default_speed
			$Hitbox.get_child(frame).set_deferred("disabled", true)
			$Hitbox.set_deferred("monitoring", false)
			$Hitbox.set_deferred("monitorable", false)
			playing = true
			set_idle()
			
	position += knockback_direction * knockback * delta
	if knockback > 0:
		knockback -= 200 * delta
	
	update()
	
func _draw():
	for i in range(max_health):
		if i <= health -1:
			draw_texture(full_heart, head_center + Vector2(-4 + (2 * i), 0))
		else:
			draw_texture(empty_heart, head_center + Vector2(-4 + (2 * i), 0))

func _on_Player_animation_finished():
	match animation:
		"attack_start":
			speed *= 0.65
			$Hitbox.set_deferred("monitoring", true)
			$Hitbox.set_deferred("monitorable", true)
			$Attack.play()
			animation = "attack"
			var mouse_direction = position.direction_to(get_global_mouse_position() + Vector2(0,-6))
			var y_angle = rad2deg(acos(mouse_direction.y))
			frame = floor((y_angle/22.5)+0.5)
			"""if y_angle < 11.25:
				frame = 0
			elif y_angle < 45:
				frame = 1
			elif y_angle < 80:
				frame = 2
			elif y_angle < 100:
				frame = 3
			elif y_angle < 120:
				frame = 4
			elif y_angle < 145:
				frame = 5
			elif y_angle < 165:
				frame = 6
			elif y_angle < 165:
				frame = 7
			else:
				frame = 8"""
			$Hitbox.get_child(frame).set_deferred("disabled", false)
			attack_timer = attack_time
			playing = false
		"attack":
			pass
		"slide_start":
			speed *= 4
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			animation = "slide"
			$Slide.play()
		"slide":
			speed = default_speed
			$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
			animation = "slide_end"
		"slide_end":
			set_idle()
		"walking":
			play("walking")
		"ghost_walk":
			play("ghost_walk")
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
			knockback_direction = position.direction_to(area.get_parent().position) * -1
			if health <= 0:
				if knockback_direction.x > 0:
					flip_h = false
				else:
					flip_h = true
				knockback = 200
				dead = true
				play("ghost_idle")
				$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
				$Hitbox.set_deferred("monitoring", false)
				$Hitbox.set_deferred("monitorable", false)
			else:
				knockback = 100
			emit_signal("health_updated", health)


func _on_Hitbox_area_entered(area):
	if area.get_name() == 'Hurtbox':
		slowdown_timer = 0.01
		if not game_over:
			match area.get_parent().tag:
				"Hopper":
					score += 15
				"Floater":
					score += 15
