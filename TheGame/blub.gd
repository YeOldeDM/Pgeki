
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var HEARTS = 3
var is_hit=false
var hit_timer=0

var bounce_timer=0
var BOUNCE_RATE = 120
var BOUNCE_VELOCITY = 100.0
var first_land=false

var POINT_VALUE = 100

var spear_class = preload('res://spear.gd')
var player_class = preload('res://player.gd')


func _die():
	get_node('/root/globals').SCORE += POINT_VALUE
	print("+",POINT_VALUE," points!")
	get_node('/root/Root/hud/Bar/ScoreValue')._activate()
	queue_free()

func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	var step = state.get_step()				#time delta
	
	if (bounce_timer >= BOUNCE_RATE):
		lv.y -= BOUNCE_VELOCITY * 0.6
		
		
		bounce_timer = 0

	if( bounce_timer <= 0 and first_land):
		var face = -1.0
		var player_x = get_node('/root/Root/Toon').get_pos().x
	
		var my_x = get_pos().x
		if(player_x > my_x):
			face = 1.0
		lv.x += ((BOUNCE_VELOCITY*20)*face)*step
		get_node('animator').play('bounce')
	#contact handling
	for i in range(state.get_contact_count()):
		var col = state.get_contact_collider_object(i)
		var nor = state.get_contact_local_normal(i)
		
		if(col):
			if(first_land):
				bounce_timer += 1
			else:
				first_land=true
			#if we are hit with the spear..
			if(col extends spear_class and not is_hit):
				print(get_name(),": I got spear'd!")
				HEARTS -= 1
				if(HEARTS <=0):
					_die()
				col.call('done')
				is_hit=true
				break
			elif (col == get_node('/root/Root/Toon') and not is_hit):
				get_node('/root/Root/Toon').get_hit(self)
	if (is_hit):
		hit_timer += 1
		if(hit_timer >= 20):
			is_hit=false
	
	lv += state.get_total_gravity()*step
	state.set_linear_velocity(lv)
	
func _ready():
	# Initialization here
	pass


