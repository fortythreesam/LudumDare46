extends AnimatedSprite

export(float) var speed

# Called when the node enters the scene tree for the first time.
func _ready():
	play("walk")

func _process(delta):
	position += Vector2(-1, 0) * speed * delta
