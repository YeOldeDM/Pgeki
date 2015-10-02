
extends RigidBody2D

#####
#	Basic Character Motion
#	based on the Demo by Juan Linietsky
#####

#Spear preload
var spear = preload('res://spear.xml')

#Character States#
var animation = ''
var facing = 1

#State Switches#
var is_jumping = false
var did_jump = false
var stopping_jump=false
var did_step = 0
var did_shoot=false


#Movement Variables#
var WALK_ATK = 300.0
var WALK_DEC = 300.0
var WALK_MAX_SPEED = 60.0
var AIR_ATK = 150.0
var AIR_DEC = 75.0
var JUMP_VELOCITY = 130
var STOP_JUMP_FORCE = 900.0
var MAX_FLOOR_AIRBORNE_TIME = 0.15
var airborne_time = 1e20
var floor_h_velocity = 0.0

var SPEAR_SPEED = 325.0
var SPEAR_DROP = -35

var respawn_point = Vector2(100,50)



func _integrate_forces(state):

	var lv = state.get_linear_velocity()	#our current velocity
	var step = state.get_step()				#time delta
	
	var new_animation = animation
	var new_facing = facing
	
	#Get controls input
	var move_left = Input.is_action_pressed('move_left')
	var move_right = Input.is_action_pressed('move_right')
	var action = Input.is_action_pressed('action')
	var jump = Input.is_action_pressed('jump')
	var respawn = Input.is_action_pressed('respawn')
	
	#if respawn:
		#teleport us to respawn_point??
		#set_pos(respawn_point)
		
	#Deapply prev floor velocity
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	#handle spear-chucking
	if (action and not did_shoot):
		var bullet = spear.instance()
		var pos = get_pos()
		bullet.set_pos(pos)
		get_parent().add_child(bullet)
		if facing == -1:
			bullet.set_rot(deg2rad(180.0))
		bullet.set_linear_velocity( Vector2(SPEAR_SPEED*facing, SPEAR_DROP))
		PS2D.body_add_collision_exception(bullet.get_rid(),get_rid())
		did_shoot = true


	#find the floor (a contact with upward facing collision normal)
	var found_floor=false
	var floor_index = -1
	
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if (ci.dot(Vector2(0,-1))>0.6):
			found_floor = true
			floor_index = x
			
	
	if (found_floor):
		if (airborne_time > 0):
			get_node('sound').play('land')
		airborne_time=0.0
		if (did_jump and not jump):
			did_jump = false
		
	else:
		airborne_time+=step		#time we spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME
	
	#process Jump
	if(is_jumping):
		if (lv.y>0):
			#set off the jumping flag if going down
			is_jumping=false
		elif (not jump):
			stopping_jump=true
			
		if (stopping_jump):
			lv.y += STOP_JUMP_FORCE*step
			
	if (on_floor):
		#process logic when we is on the floor
		if (move_left and not move_right):
			if(lv.x > -WALK_MAX_SPEED):
				lv.x += -WALK_ATK*step
		elif(move_right and not move_left):
			if(lv.x < WALK_MAX_SPEED):
				lv.x += WALK_ATK*step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEC*step
			if (xv<0):
				xv=0
			lv.x=sign(lv.x)*xv
		
		#check jump
		if (not is_jumping and not did_jump and jump):
			lv.y=-JUMP_VELOCITY
			is_jumping=true
			stopping_jump=false
			get_node('sound').play('jump')
			did_jump = true
		#check facing
		if (lv.x < 0 and move_left):
			new_facing = -1
		elif (lv.x > 0 and move_right):
			new_facing = 1
		if (is_jumping):
			new_animation='jumping'
		elif(abs(lv.x)<0.1):
			new_animation='idle'
		else:
			new_animation='running'
			
	else:
		#process logic when we are airborne
		if(move_left and not move_right):
			if(lv.x > -WALK_MAX_SPEED):
				lv.x -= AIR_ATK*step
		elif(move_right and not move_left):
			if(lv.x < WALK_MAX_SPEED):
				lv.x += AIR_ATK*step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEC*step
			if (xv<0):
				xv=0
			lv.x=sign(lv.x)*xv
			
		if(lv.y<0):
			new_animation='jumping'
		else:
			new_animation='falling'
			
	#update facing
	if(new_facing!=facing):
		var sc = Vector2(-facing,1)
		get_node('sprite').set_scale(sc)

		facing = new_facing
		
		

	if (new_animation!=animation):
		animation=new_animation
		get_node('animator').play(animation)
	

	if (animation == 'running'):
		var frame = get_node('sprite').get_frame()
		
		if(frame == 4 or frame == 9) and did_step != frame:
			get_node('sound').play('footstep')
			did_step = frame

	#apply floor velocity
	if(found_floor):
		floor_h_velocity = state.get_contact_collider_velocity_at_pos(floor_index).x
		lv.x += floor_h_velocity
		
		
	
	#Finally, apply gravity and set back the linear velocity
	lv += state.get_total_gravity()*step
	state.set_linear_velocity(lv)
	
func done_shooting():
	did_shoot = false
	
func _ready():
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed('respawn'):
		set_pos(respawn_point)

