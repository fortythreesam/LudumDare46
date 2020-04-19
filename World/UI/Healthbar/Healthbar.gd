extends Control

var max_health:float = 1
var health:float = 1


func update_health(new_health):
	health = new_health
	$TextureProgress.value = health

func set_max_health(new_max_health):
	max_health = new_max_health
	health = new_max_health
	$TextureProgress.value = health
	$TextureProgress.max_value = max_health



func _on_Player_health_updated(new_health):
	update_health(new_health)


func _on_Player_new_max_health(new_health):
	set_max_health(new_health)
