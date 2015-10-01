
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"
var bounce_timer=0
var BOUNCE_RATE = 120
var BOUNCE_VELOCITY = 80.0

var spear_class = preload('res://spear.gd')

func _die():
	queue_free()

func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	
	#contact handling
	for i in range(state.get_contact_count()):
		var col = state.get_contact_collider_object(i)
		var nor = state.get_contact_local_normal(i)
		
		if(col):
			#if we are hit with the spear..
			if(col extends spear_class):
				print("I got spear'd!")
				_die()
				break
				
		

func _ready():
	# Initialization here
	pass


