
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

func _on_body_enter(body):
	if (body extends preload('res://player.gd')):
		get_node('/root/globals').LEMONS += 1
		get_node('/root/globals').SCORE += 5
		get_node('/root/Root/hud/Bar/ScoreValue')._activate()
		get_node('/root/Root/hud/Bar/LemonValue')._activate()
		get_node('/root/Root/Toon/sound').play('pickup')
		queue_free()


func _ready():
	connect("body_enter", self, "_on_body_enter")
	pass


