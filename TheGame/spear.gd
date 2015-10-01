
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var lifetime = -1
var TIME_LIMIT = 120
var did_hit=false
var blinker=true
var blink_timer=0

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var c = state.get_contact_collider_object(i)
		
		if (c):
			set_mode(MODE_STATIC)
			lifetime += 1
			if (not did_hit):
				did_hit = true
				get_node('sound').play('hit')

func _ready():
	set_process(true)
	
func _process(delta):
	var visible = get_node('visibility').is_on_screen() == true

	
	if (not visible):
		done()
	elif(lifetime>=0):
		lifetime += 1
		if(lifetime>=TIME_LIMIT):
			done()
		if(lifetime >= TIME_LIMIT*0.65):	
			blink()
func done():
	get_parent().get_child(0).call('done_shooting')
	queue_free()

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
