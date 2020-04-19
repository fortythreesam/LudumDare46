extends Node2D

var cactus = preload("res://World/Environment/Cactus.tscn")
var rock = preload("res://World/Environment/Rock.tscn")

var floater = preload("res://Enemies/Floater/Floater.tscn")
var hopper = preload("res://Enemies/Hopper/Hopper.tscn")

const floater_cost: int = 10
const hopper_cost: int = 15

var points: float
var timer: float
var points_inc_value: float

var game_over: bool = false

export(int) var num_scenery
export(int) var difficulty

func _ready():
	generete_scenery(num_scenery)
	timer = 1
	points = 0
	points_inc_value = 0


func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	
	if not game_over:
		for child in $Entities/PlayerEnemies.get_children():
			child.set_target($Entities/Player.position)
			
		for child in $Entities/ItEnemies.get_children():
			child.set_target($Entities/It.position)
	
		timer += delta
		if timer >= difficulty:
			points_inc_value += 1
			timer = 0
			spend_points()
		points += ((1 + points_inc_value) * delta)
		
		if $Entities/It.dead:
			game_over = true
	else:
		for child in $Entities/PlayerEnemies.get_children():
			child.remove_target()
		for child in $Entities/ItEnemies.get_children():
			child.remove_target()
		$MainCamera/Control/GameOverMessage.show()
	
	$MainCamera.position = ($Entities/NPC.position + $Entities/Player.position) / 2
	
	

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
		
func spend_points():
	while points >= 10:
		var affordable = can_afford()[0]
		var costs = can_afford()[1]
		var new_enemy_index = floor(rand_range(0,affordable.size()))
		var new_enemy = affordable[new_enemy_index].instance()
		points -= costs[new_enemy_index]
		var spawn_y
		if floor(rand_range(0,2)) == 0:
			spawn_y = rand_range(600,800)
		else:
			spawn_y = rand_range(-200,-400)
		new_enemy.position = Vector2(rand_range($Entities/NPC.position.x - 2000, $Entities/NPC.position.x - 500), spawn_y)
		if floor(rand_range(0,2)) == 0:
			$Entities/PlayerEnemies.add_child(new_enemy)
		else:
			$Entities/ItEnemies.add_child(new_enemy)
		

func can_afford():
	var affordable = []
	var costs = []
	if points >= hopper_cost:
		affordable += [hopper]
		costs += [hopper_cost]
	if points >= floater_cost:
		affordable += [floater]
		costs += [floater_cost]
	return [affordable, costs]
