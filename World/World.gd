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
	
	if not game_over:
		timer += delta
		if timer >= difficulty:
			points_inc_value += 1
			difficulty += 1
			timer = 0
			spend_points()
		points += ((1 + points_inc_value) * delta)
		
		if $Entities/It.dead:
			game_over = true
			$Entities/Player.game_over = true
			$Entities/NPC.game_over = true
			$MainCamera/Control/Score.text = str($Entities/Player.score)
			
	else:
		$MainCamera/Control/GameOverMessage.show()
		$MainCamera/Control/Score.show()
		
	$Entities/Player.healer_location = $Entities/NPC.position
	
	for child in $Entities/PlayerEnemies.get_children():
		if not $Entities/Player.dead:
			child.set_target($Entities/Player.position)
		elif not $Entities/It.dead:
			child.set_target($Entities/It.position)
		elif not $Entities/NPC.dead:
			child.set_target($Entities/NPC.position)
		else:
			child.remove_target()
		
	for child in $Entities/ItEnemies.get_children():
		if not $Entities/It.dead:
			child.set_target($Entities/It.position)
		elif not $Entities/Player.dead:
			child.set_target($Entities/Player.position)
		elif not $Entities/NPC.dead:
			child.set_target($Entities/NPC.position)
		else:
			child.remove_target()
		
	for child in $Entities/NPCEnemies.get_children():
		if not $Entities/NPC.dead:
			child.set_target($Entities/NPC.position)
		elif not $Entities/It.dead:
			child.set_target($Entities/It.position)
		elif not $Entities/Player.dead:
			child.set_target($Entities/Player.position)
		else:
			child.remove_target()
	
	$MainCamera.position = ($Entities/It.position + $Entities/Player.position) / 2
	$MainTheme.position = $MainCamera.position
	
func _input(event):
	if event.is_action_released("ui_cancel"):
		get_tree().paused = true
		$MainCamera/Control/Pause.show()
	
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
			spawn_y = rand_range(500,600)
		else:
			spawn_y = rand_range(-100,-200)
		new_enemy.position = Vector2(rand_range($MainCamera.position.x - 1000, $MainCamera.position.x - 500), spawn_y)
		if floor(rand_range(0,3)) == 0:
			$Entities/PlayerEnemies.add_child(new_enemy)
		elif floor(rand_range(0,2)) == 0:
			$Entities/ItEnemies.add_child(new_enemy)
		else:
			$Entities/NPCEnemies.add_child(new_enemy)
		

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


func _on_Pause_unpause():
	get_tree().paused = false


func _on_MainTheme_finished():
	$MainTheme.play(0.0)
