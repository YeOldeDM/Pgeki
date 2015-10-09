
extends RigidBody2D


#  HEALTH & DAMAGE-TAKING #
###########################
var HITS = 3
var HIT_DURATION = 20
var is_hit=false
var hit_timer=0

# BOUNCING PARAMS #
###################
var bounce_timer=0
var BOUNCE_RATE = 120
var BOUNCE_VELOCITY = 100.0

var first_land=false	#Hack: Keeps the Blub from zooming toward the player if spawned in mid-air

# POINTS 
var POINT_VALUE = 100

# CLASS REFERENCES
var spear_class = preload('res://spear.gd')
var player_class = preload('res://player.gd')

# BLINKER PARAMS #
##################
var blinker=false
var blink_timer=0
var blink_freq1 = 2
var blink_freq2 = 3




# Death takes me!
func _die():
	get_node('/root/globals').SCORE += POINT_VALUE
	print("+",POINT_VALUE," points!")
	get_node('/root/Root/hud/Bar/ScoreValue')._activate()
	queue_free()

# CUSTOM PHYSICS INTEGRATION #
##############################
func _integrate_forces(state):
	var lv = state.get_linear_velocity()	#our velocity
	var step = state.get_step()				#time delta
	
	# Bounce me at a rate
	if (bounce_timer >= BOUNCE_RATE):
		lv.y -= BOUNCE_VELOCITY * 0.6		# hacky-looking 0.6 is hacky
		bounce_timer = 0
	
	
	if( bounce_timer <= 0 and first_land):
		var face = -1.0
		var player_x = get_node('/root/Root/Toon').get_pos().x
		
		#decide whether the player is to our left or right, and bounce that way
		var my_x = get_pos().x
		if(player_x > my_x):
			face = 1.0
		lv.x += ((BOUNCE_VELOCITY*20)*face)*step	#hacky-looking 20 is hacky
		get_node('animator').play('bounce')			#Boing!
		
		
	#contact handling
	for i in range(state.get_contact_count()):
		var col = state.get_contact_collider_object(i)
		var nor = state.get_contact_local_normal(i)
		
		if(col):
			if(first_land):
				bounce_timer += 1	#count up our timer as soon as we hit the ground
			else:
				first_land=true	#We've touched land for the first time
				
			#if we are hit with the spear..
			if(col extends spear_class and not is_hit):
				print(get_name(),": I got spear'd!")
				HITS -= 1
				#if it kills us..
				if(HITS <=0):
					_die()
				#kill the spear
				col.call('done')
				#notify that we are now 'hit'
				is_hit=true
				break
			#Hit the player on contact (1 dmg)
			elif col extends player_class and not is_hit:
				col.get_hit(self)	

	if (is_hit):
		#blink!
		get_node('/root/globals').blink(self)
		
		hit_timer += 1
		#take us out of hit mode after time
		if(hit_timer >= HIT_DURATION):
			is_hit=false
	else:
		#make sure our blinker isn't leaving us invisible when it stops!
		get_node('sprite').set_modulate(Color(1.0,1.0,1.0,1.0))
	
	# FINALLY, apply gravity and set velocity
	lv += state.get_total_gravity()*step
	state.set_linear_velocity(lv)
	



