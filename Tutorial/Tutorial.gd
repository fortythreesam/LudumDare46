extends Node2D

var cactus = preload("res://World/Environment/Cactus.tscn")
var rock = preload("res://World/Environment/Rock.tscn")

var floater = preload("res://Enemies/Floater/Floater.tscn")
var hopper = preload("res://Enemies/Hopper/Hopper.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	generete_scenery(2000)


func _process(delta):
	$MainCamera.position = ($Entities/It.position + $Entities/Player.position) / 2


func generete_scenery(n):
	for i in range(n):
		var spawn_location = Vector2(ceil(rand_range(-10000, 1000)), ceil(rand_range(-500, 800)))
		var new_cactus = cactus.instance()
		new_cactus.position = spawn_location
		$Entities/Scenery.add_child(new_cactus)
		
	for i in range(n):
		var spawn_location = Vector2(ceil(rand_range(-10000, 1000)), ceil(rand_range(-500, 800)))
		var new_rock = rock.instance()
		new_rock.position = spawn_location
		$Entities/Scenery.add_child(new_rock)
