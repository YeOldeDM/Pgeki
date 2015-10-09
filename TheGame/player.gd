
extends RigidBody2D

#########################################
#	Basic Character Motion				#
#	based on the Demo by Juan Linietsky	#
#########################################

# Mob Spawner #
var mob = preload('res://blub.xml')
var lemon = preload('res://lemon.xml')

# Spear preload #
var spear = preload('res://spear.xml')

# Character States #
var animation = ''
var facing = 1
var scale = 1

# State Switches #
var is_jumping = false
var did_jump = false
var stopping_jump=false
var did_step = 0
var did_shoot=false
var can_shoot=true
var is_hit=false

# timers #
var hit_timer=0
var hit_timelimit = 2.0	#seconds of invulnerability after being hit

# blinker params
var blink_freq1 = 2
var blink_freq2 = 1

var blinker=true
var blink_timer=0

# Movement Variables #
var WALK_ATK = 320.0
var WALK_DEC = 420.0
var WALK_MAX_SPEED = 64.0
var AIR_ATK = 120.0
var AIR_DEC = 20.0
var JUMP_VELOCITY = 1.4
var MAX_AIR_SPEED = 68.0
var STOP_JUMP_FORCE = 900.0
var MAX_FLOOR_AIRBORNE_TIME = 0.15
var airborne_time = 1e20
var floor_h_velocity = 0.0

var SPEAR_SPEED = 450.0
var SPEAR_DROP = -40.0

var respawn_point = Vector2(100,50)

var lemon_class = preload('res://lemon.gd')

#################################
#	Custom physics integration	#
#################################
func _integrate_forces(state):

	var lv = state.get_linear_velocity()	#our current velocity
	var step = state.get_step()				#time delta
	
	var new_animation = animation
	var new_facing = facing
	
	
	

	#  GET INPUT  #
	###############
	var move_left = Input.is_action_pressed('move_left')
	var move_right = Input.is_action_pressed('move_right')
	var action = Input.is_action_pressed('action')
	var unaction = Input.is_action_pressed('action') == false
	var jump = Input.is_action_pressed('jump')
	var respawn = Input.is_action_pressed('respawn')
	

	#Deapply prev floor velocity
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	
	
	#  SPEAR THROWING  #
	####################
	if (action and can_shoot and not did_shoot):
		var bullet = spear.instance()
		var pos = get_pos()
		bullet.set_pos(pos)
		get_parent().add_child(bullet)
		if facing == -1:	#Rotate if facing left
			bullet.set_rot(deg2rad(180.0))
		
		#set spear velocity
		bullet.set_linear_velocity( Vector2(SPEAR_SPEED*facing, SPEAR_DROP))
		
		#add us as a collision exception
		#keeps us from shooting ourself in the foot ;)
		PS2D.body_add_collision_exception(bullet.get_rid(),get_rid())
		
		#rate of fire switch
		did_shoot = true
		can_shoot = false
		
		#play SFX
		get_node('sound').play('toss')
	elif unaction:
		can_shoot = true


	#  FLOOR COLLISION  #
	#####################
	var found_floor=false
	var floor_index = -1
	
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if (ci.dot(Vector2(0,-1))>0.6):		#check slope for 'floor'
			found_floor = true
			floor_index = x

			
			
	#We have landed on the floor
	if (found_floor):
		if (airborne_time > 0):
			get_node('sound').play('land')
		airborne_time=0.0
		if (did_jump and not jump):
			did_jump = false
	#We are airborne
	else:
		airborne_time+=step		#time we spent in the air
	
	#if we are airborne for a moment, we are no longer on_floor
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME
	
	#  JUMPING  #
	#############
	if(is_jumping):
		if (lv.y>0):
			#set off the jumping flag if we're going down
			is_jumping=false
		elif (not jump):
			#we let go of jump, so make us drop (Metroid-style)
			stopping_jump=true
			
		if (stopping_jump):
			#push us downward if we are stop_jumping
			lv.y += STOP_JUMP_FORCE*step
	
	
	#  ON-FLOOR LOGIC  #
	####################
	if (on_floor):
		#we are moving left
		if (move_left and not move_right):
			if(lv.x > -WALK_MAX_SPEED):	#throttle control
				lv.x += -WALK_ATK*step	#apply velocity
				
		#we are moving right
		elif(move_right and not move_left):
			if(lv.x < WALK_MAX_SPEED):	#throttle control
				lv.x += WALK_ATK*step	#apply velocity
				
		#we are not moving, so decelerate
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEC*step
			if (xv<0):
				xv=0
			lv.x=sign(lv.x)*xv
		
		# Trigger Jump
		if (not is_jumping and not did_jump and jump):
			lv.y=-JUMP_VELOCITY * get_mass()				#Apply velocity
			is_jumping=true					#switch: we are jumping
			stopping_jump=false				#switch: we are not stop-jumping
			did_jump = true					#switch: we did jump (and cannot again until we release the command)
			
			get_node('sound').play('jump')	#boing!
			
		# Get/Set Facing
		# -1 = facing left
		#  1 = facing right
		if (lv.x < 0 and move_left):
			new_facing = -1
		elif (lv.x > 0 and move_right):
			new_facing = 1
			
		#Set animation
		if (is_jumping):
			new_animation='jumping'
		elif(abs(lv.x)<0.1):
			new_animation='idle'
		else:
			new_animation='running'
	
	#  IN-AIR LOGIC  #
	##################
	else:
		#moving right in mid-air
		if(move_left and not move_right):
			if(lv.x > -WALK_MAX_SPEED):	#throttle control
				lv.x -= AIR_ATK*step	#set velocity
		
		#moving left in mid-air
		elif(move_right and not move_left):
			if(lv.x < WALK_MAX_SPEED):	#throttle control
				lv.x += AIR_ATK*step	#seet velocity
		
		#not moving in mid-air, so decelerate
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEC*step
			if (xv<0):
				xv=0
			lv.x=sign(lv.x)*xv
			
		if lv.x < -MAX_AIR_SPEED:
			lv.x = -MAX_AIR_SPEED
		elif lv.x > MAX_AIR_SPEED:
			lv.x = MAX_AIR_SPEED
			
		# Set Animation
		if(lv.y<0):
			new_animation='jumping'
		else:
			new_animation='falling'
			
	#Update sprite scale to reflect new facing
	if(new_facing!=facing):
		var sc = Vector2(-facing,1)*scale
		get_node('sprite').set_scale(sc)

		facing = new_facing
		
		
	# Play Animation
	if (new_animation!=animation):
		animation=new_animation
		get_node('animator').play(animation)
	
	# Play footstep SFX based on running animation
	if (animation == 'running'):
		var frame = get_node('sprite').get_frame()
		
		if(frame == 4 or frame == 9) and did_step != frame:		#Pgeki puts a foot down on frame #4 & #9
			get_node('sound').play('step')
			did_step = frame

	#  APPLY VELOCITIES TO OUR RIGIDBODY  #
	#######################################
	if(found_floor):
		#(not certain exactly what this does. it's important though!
		floor_h_velocity = state.get_contact_collider_velocity_at_pos(floor_index).x
		lv.x += floor_h_velocity

	#Finally, apply gravity and set back the linear velocity
	lv += state.get_total_gravity()*step
	state.set_linear_velocity(lv)


#	Hook for spear script:
#	Our spear is freed, so we can fire another
func done_shooting():
	did_shoot = false


#################################
#	I Get Hit by Something!		#
#################################
func get_hit(origin, amt=1):
	if not is_hit:	#if we're not already hit
		var life = get_node('/root/globals').LIFE	#get global Life value
		
		if(life>0):	#if we are not dead yet..
			life -= amt	#lose some life 
			
		get_node('/root/globals').LIFE = life		#set global Life value
		
		# kick-back from damage
		var target_pos = origin.get_pos()	#position of origin
		var my_pos = get_pos()				#my position
		var vect = target_pos - my_pos		#Vector between the two


		set_linear_velocity(-vect*12)		#set velocity inverted and amplified
		
		#call draw function to HUD Hearts
		get_node('/root/Root/hud/hearts')._draw_hearts()
		
		#switch: we are hit, and invulnerable for a moment
		is_hit=true

	
	
func _ready():
	# Initialize
	set_process(true)



func _process(delta):

	# DEV HACK: Teleport to initial scene position
	if Input.is_action_pressed('respawn'):
		set_pos(respawn_point)
		
	#DEV HACK: Spawn a Blub (or twenty) behind you
	if Input.is_action_pressed('DEV_spawn_blub'):
		var guy = lemon.instance()
		var pos = get_pos()
		pos.x -= 10*facing
		pos.y -= 10
		guy.set_pos(pos)
		get_parent().add_child(guy)
	
	# Handle hit timer if we are hit
	if is_hit:
		hit_timer += delta
		get_node('/root/globals').blink(self)
		if hit_timer >= hit_timelimit:
			hit_timer=0
			is_hit=false
			get_node('sprite').set_modulate( Color(1.0,1.0,1.0,1.0) )
		
		

