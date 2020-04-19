extends AnimatedSprite

export(float) var walk_speed := 20

var target:Vector2
var move_direction:Vector2
var dead: bool = false

var flicker_timer: float = 0;

func _ready():
	remove_target()
	play("default")

func _process(delta):
	if not dead:
		if target != null:
			move_direction = Vector2(sign(floor(target.x - position.x)), sign(floor(target.y - position.y)))
			position += move_direction.normalized() * walk_speed * delta
			if move_direction.x > 0:
				flip_h = false
			elif move_direction.x < 0:
				flip_h = true
	
	if flicker_timer > 0:
		modulate = Color(100,100,100)
		flicker_timer -= delta
	else: 
		modulate = Color(1,1,1)
		
func set_target(new_target:Vector2):
	target = new_target
	
func remove_target():
	target = position

func _on_Hitbox_area_entered(area):
	if area.get_name() == "Hurtbox":
		kill()

func _on_Hurtbox_area_entered(area):
	if area.get_name() == "Hitbox":
		kill()

func kill():
	if not dead: 
		flicker_timer = 0.1
		dead = true
		play('dying')
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	

func _on_Floater_animation_finished():
	match animation:
		"dying":
			play('dead')
