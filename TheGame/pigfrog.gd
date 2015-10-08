
extends RigidBody2D

const STATE_WALKING = 0
const STATE_DYING = 1

var mystate = STATE_WALKING

var direction = -1

var animation = ''

var rc_left=null
var rc_right=null
var WALK_SPEED = 28

var spear_class = preload('res://spear.gd')

func _die():
	queue_free()
	
func _pre_die():
	clear_shapes()
	set_mode(MODE_STATIC)
	#get_node('sound').play('death')
	


func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	var new_animation = animation
	
	if mystate == STATE_DYING:
		pass
	elif mystate == STATE_WALKING:
		new_animation = 'walk'
		
		var wall_side = 0.0
		
		for i in range(state.get_contact_count()):
			var col = state.get_contact_collider_object(i)
			var norm = state.get_contact_local_normal(i)
			
			if col:
				if col extends spear_class:
					set_mode(MODE_RIGID)
					mystate = STATE_DYING
					state.set_angular_velocity(sign(norm.x)*33.0)
					set_friction(1)
					col.done()
					#get_node('sound').play('death')
					
					break
					
			if norm.x > 0.9:
				wall_side = 1.0
			elif norm.x < -0.9:
				wall_side = -1.0
		if (wall_side != 0 and wall_side != direction):
			direction = -direction

		if (direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding()):
			direction = -direction
		elif (direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding()):
			direction = -direction

			
		lv.x = direction * WALK_SPEED
		
	if (animation != new_animation):
		animation = new_animation
		get_node('animator').play(animation)
		
	state.set_linear_velocity(lv)
	
func _ready():
	rc_left = get_node('raycast_left')
	rc_right = get_node('raycast_right')


