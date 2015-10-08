
extends RigidBody2D

const STATE_WALKING = 0
const STATE_ATTACKING = 1
const STATE_DYING = 2

var mystate = STATE_WALKING

var direction = -1

var animation = ''

var rc_left=null
var rc_right=null
var WALK_SPEED = 28

var spear_class = preload('res://spear.gd')
var bullet = preload('res://phlem.xml')

var fire_timer = 0
var fire_rate = 200

var did_shoot=false

func _die():
	queue_free()
	
func _pre_die():
	pass
	#get_node('sound').play('death')
	


func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	var new_animation = animation
	
	if mystate == STATE_DYING:
		pass
	elif mystate == STATE_ATTACKING:
		lv.x = 0
		new_animation = 'attack'
		var anim_pos = get_node('animator').get_current_animation_pos()

		if anim_pos >= get_node('animator').get_current_animation_length()-0.1:
			print('time to walk!')
			mystate = STATE_WALKING
			did_shoot = false
		elif anim_pos >= 1.0:
			_shoot()
		
	elif mystate == STATE_WALKING:
		new_animation = 'walk'
		
		var wall_side = 0.0
		
		for i in range(state.get_contact_count()):
			var col = state.get_contact_collider_object(i)
			var norm = state.get_contact_local_normal(i)
			
			if col:
				if col extends spear_class:
					#set_mode(MODE_RIGID)
					mystate = STATE_DYING
					#state.set_angular_velocity(sign(norm.x)*33.0)
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
	fire_timer += 1
	if fire_timer >= fire_rate:
		mystate = STATE_ATTACKING
		fire_timer = 0
		
	if (animation != new_animation):
		animation = new_animation
		get_node('animator').play(animation)
		
	state.set_linear_velocity(lv)

func _ready():
	rc_left = get_node('raycast_left')
	rc_right = get_node('raycast_right')

func _shoot():
	if not did_shoot:
		print("ACHOO!!")
		did_shoot=true
		
		var left_pos = get_pos()
		left_pos.x -= 6
		var shot = bullet.instance()
		shot.set_rot(deg2rad(180.0))
		shot.set_pos(left_pos)
		get_parent().add_child(shot)
		PS2D.body_add_collision_exception(shot.get_rid(),get_rid())
		shot.set_linear_velocity( Vector2(-100,0) )
		
		var right_pos = get_pos()
		right_pos.x += 6
		var shot = bullet.instance()
		#shot.set_rot(deg2rad(180.0))
		shot.set_pos(right_pos)
		get_parent().add_child(shot)
		PS2D.body_add_collision_exception(shot.get_rid(),get_rid())
		shot.set_linear_velocity( Vector2(100,0) )
