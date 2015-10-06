
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed('Start'):
		get_tree().change_scene('res://game.scn')


