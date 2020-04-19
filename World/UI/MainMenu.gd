extends Node2D

export(Curve) var camera_curve

var cactus = preload("res://World/Environment/Cactus.tscn")
var rock = preload("res://World/Environment/Rock.tscn")

var index:int = 0
var volume: float
var show_tutorial: bool = false
var camera_destination: Vector2
var max_camera_distance: float = 272
var camera_speed: float = 800

# Called when the node enters the scene tree for the first time.
func _ready():
	generete_scenery(10)
	camera_destination = Vector2(240, 136)
	max_camera_distance = 272
	show_tutorial = false
	$Camera2D.position = Vector2(240, 136)


func _process(delta):
	volume = 50 + AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"));
	$Control/Node/Volume.text = "Volume: " + str(volume)
	for l in $Control/Node.get_children():
		l.modulate = Color('#ffffff')
	$Control/Node.get_child(index).modulate = Color('#eed947')
				
	var camera_distance = $Camera2D.position.distance_to(camera_destination) / max_camera_distance
	$Camera2D.position.y += camera_curve.interpolate(camera_distance) * delta * camera_speed * sign(camera_destination.y - $Camera2D.position.y)
				
	if not show_tutorial:
		camera_destination = Vector2(240, 136)
	else:
		camera_destination = Vector2(240, 408)
				
func _input(event):
	if event.is_action_released("ui_cancel"):
		if not show_tutorial:
			get_tree().quit()
		else:
			show_tutorial = false
	if event.is_action_released("ui_right"):	
		match $Control/Node.get_child(index).get_name():
			"Volume":
				$MenuSound.play()
				volume += 1
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume - 50)
	if event.is_action_released("ui_left"):	
		match $Control/Node.get_child(index).get_name():
			"Volume":
				$MenuSound.play()
				volume -= 1
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume - 50)
	if event.is_action_released("ui_up"):
		$MenuSound.play()
		index -= 1
		if index < 0:
			index = $Control/Node.get_child_count() - 1
	if event.is_action_released("ui_down"):
		$MenuSound.play()
		index += 1
		if index > $Control/Node.get_child_count() - 1:
			index = 0
	if event.is_action_released("ui_accept"):
		match $Control/Node.get_child(index).get_name():
			"StartGame":
				get_tree().change_scene("res://World/World.tscn")
			"Tutorial":
				show_tutorial = true
			"Fullscreen":
				OS.window_fullscreen = !OS.window_fullscreen
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


func _on_StartGame_mouse_entered():
	index = 0
	$MenuSound.play()


func _on_Tutorial_mouse_entered():
	index = 1
	$MenuSound.play()

func _on_Fullscreen_mouse_entered():
	index = 2
	$MenuSound.play()

func _on_Volume_mouse_entered():
	index = 3
	$MenuSound.play()

func _on_Quit_mouse_entered():
	index = 4
	$MenuSound.play()

func _on_BackgroundMusic_finished():
	$BackgroundMusic.play(0)



