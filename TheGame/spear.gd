
extends RigidBody2D

# Parameters
var TIME_LIMIT = 60	#Spear Lifetime (if not view-culled), in frames
var THROW_ATK=13	#frames before throwing

# Switches
var pre_throw=true
var did_hit=false


# Holders
var lifetime = -1

# Timers
var hold_timer=0

# blinker params
var blink_freq1 = 1
var blink_freq2 = 5

var blinker=true
var blink_timer=0



#  CUSTOM PHYSICS INTEGRATION  #
################################
func _integrate_forces(state):
	# Handle Collision
	for i in range(state.get_contact_count()):
		var c = state.get_contact_collider_object(i)
		
		if (c):	#Contact!
			set_mode(MODE_STATIC)	#Stick to the collider
			lifetime += 1			#increase lifetime from -1 (causing it to start the timer)
			if (not did_hit):		#switch: we hit
				did_hit = true
				get_node('sound').play('hit')	#Thud!
				get_node('animator').play('thunk')

func _ready():
	# Initialize!
	set_process(true)



func _process(delta):
	#Holder for screen visibility
	var visible = get_node('visibility').is_on_screen() == true

	if (not visible):
		done()	#we have gone off-screen. We are done.
		
	elif(lifetime>=0):	#if not -1:
		lifetime += 1	#increase the timer
		
		if(lifetime>=TIME_LIMIT):
			done()	#our timelimit is up. We are done.
			
		if(lifetime >= TIME_LIMIT*0.65):	#Start blinking 65% into our life time
			get_node('/root/globals').blink(self)


func done():	#Tell the player he can shoot again, then kill ourselves
	get_node('/root/Root/Toon').call('done_shooting')
	queue_free()

# Hackity blink logic
# This should become modular, for any object that blinks
func blink():
	if(blinker):
		blink_timer += 1
		if(blink_timer > 2):
			get_child(0).set_modulate(Color(1.0,1.0,1.0,0.0))
			blink_timer = 0
			blinker=false
	else:
		blink_timer += 1
		if(blink_timer > 3):
			get_child(0).set_modulate(Color(1.0,1.0,1.0,1.0))
			blink_timer = 0
			blinker=true
