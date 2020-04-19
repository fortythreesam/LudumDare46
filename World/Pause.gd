extends Control


var index:int = 0
signal unpause
var volume: float

func _process(delta):
	if visible:
		volume = 50 + AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"));
		$MenuItems/Volume.text = "Volume: " + str(volume)
		for l in $MenuItems.get_children():
			l.modulate = Color('#ffffff')
		$MenuItems.get_child(index).modulate = Color('#eed947')
	

func _input(event):
	if visible:
		if event.is_action_released("ui_up"):
			$MenuSound.play()
			index -= 1
			if index < 0:
				index = $MenuItems.get_child_count() - 1
		if event.is_action_released("ui_down"):
			$MenuSound.play()
			index += 1
			if index > $MenuItems.get_child_count() - 1:
				index = 0
		if event.is_action_released("ui_right"):	
			match $MenuItems.get_child(index).get_name():
				"Volume":
					$MenuSound.play()
					volume += 1
					AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume - 50)
		if event.is_action_released("ui_left"):	
			match $MenuItems.get_child(index).get_name():
				"Volume":
					$MenuSound.play()
					volume -= 1
					AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume - 50)
		if event.is_action_released("ui_accept"):
			match $MenuItems.get_child(index).get_name():
				"Return":
					emit_signal("unpause")
					hide()
				"MainMenu":
					emit_signal("unpause")
					get_tree().change_scene("res://World/UI/MainMenu.tscn")
				"Fullscreen":
					OS.window_fullscreen = !OS.window_fullscreen
				"Quit":
					get_tree().quit()


func _on_Return_mouse_entered():
	index = 0
	$MenuSound.play()

func _on_Volume_mouse_entered():
	index = 1
	$MenuSound.play()
	
func _on_Fullscreen_mouse_entered():
	index = 2
	$MenuSound.play()

func _on_MainMenu_mouse_entered():
	index = 3
	$MenuSound.play()

func _on_Quit_mouse_entered():
	index = 4
	$MenuSound.play()


