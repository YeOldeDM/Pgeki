
extends RigidBody2D

var blinker=false
var blink_timer=0
var blink_freq1 = 1
var blink_freq2 = 2

var active=true
var player_class = preload('res://player.gd')

func _on_body_enter(body):
	if active and body extends player_class:
		body.get_hit(self,2)
		

func _integrate_forces(state):
	var lv = get_linear_velocity()
	lv.x *= 0.9
	"""
	for i in range(state.get_contact_count()):
		var col = state.get_contact_collider_object(i)
		
		if active and col == get_node('/root/Root/Toon'):
			get_node('/root/Root/Toon').get_hit(self)
	"""
	if abs(lv.x) < 100.0:
		lv.x *= 0.99
		get_node('/root/globals').blink(self)
		get_node('animator').stop()
		active=false
	if abs(lv.x) < 3.0:
		_die()
	
	
	
	set_linear_velocity(lv)
	
func _die():
	queue_free()

func _ready():
	# Initialization here
	pass


