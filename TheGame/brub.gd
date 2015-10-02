
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var HEARTS = 3
var is_hit=false
var hit_timer=0

var bounce_timer=0
var BOUNCE_RATE = 120
var BOUNCE_VELOCITY = 80.0

var POINT_VALUE = 100

var spear_class = preload('res://spear.gd')

func _die():
	get_node('/root/globals').SCORE += POINT_VALUE
	queue_free()

func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	
	#contact handling
	for i in range(state.get_contact_count()):
		var col = state.get_contact_collider_object(i)
		var nor = state.get_contact_local_normal(i)
		
		if(col):
			#if we are hit with the spear..
			if(col extends spear_class and not is_hit):
				print("I got spear'd!")
				HEARTS -= 1
				if(HEARTS <=0):
					_die()
				col.call('done')
				is_hit=true
				break
				
	if (is_hit):
		hit_timer += 1
		if(hit_timer >= 20):
			is_hit=false
			
func _ready():
	# Initialization here
	pass


