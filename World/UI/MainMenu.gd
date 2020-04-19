extends Node2D


var cactus = preload("res://World/Environment/Cactus.tscn")
var rock = preload("res://World/Environment/Rock.tscn")

var index:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	generete_scenery(10)


func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	for l in $Control/Node.get_children():
		l.modulate = Color('#ffffff')
	$Control/Node.get_child(index).modulate = Color('#eed947')
	if Input.is_action_just_released("ui_up"):
		$MenuSound.play()
		index -= 1
		if index < 0:
			index = $Control/Node.get_child_count() - 1
	if Input.is_action_just_released("ui_down"):
		$MenuSound.play()
		index += 1
		if index > $Control/Node.get_child_count() - 1:
			index = 0
	if Input.is_action_just_released("ui_accept"):
		match $Control/Node.get_child(index).get_name():
			"StartGame":
				get_tree().change_scene("res://World/World.tscn")
			"Quit":
				get_tree().quit()
	


func generete_scenery(n):
	for i in range(n):
		var spawn_location = Vector2(ceil(rand_range(0, 480)), ceil(rand_range(0, 270)))
		var new_cactus = cactus.instance()
		new_cactus.position = spawn_location
		$Entities/Scenery.add_child(new_cactus)
		
	for i in range(n):
		var spawn_location = Vector2(ceil(rand_range(0, 480)), ceil(rand_range(0, 270)))
		var new_rock = rock.instance()
		new_rock.position = spawn_location
		$Entities/Scenery.add_child(new_rock)
