
extends Label

# member variables here, example:
# var a=2
# var b="textvar"
var my_lemons = 0
var real_lemons = 0

var is_active=false


func _draw_score(delta):
	real_lemons = get_node('/root/globals').LEMONS
	
	# Reset at 100 Lemons
	if real_lemons > 99:
		get_node('/root/globals/').LEMONS -= 100
		my_lemons -= 100
		#Give a 1UP
	
	# Adjust my score to match real score
	if (int(my_lemons)!=real_lemons):
		if(my_lemons < real_lemons):
			my_lemons += delta*50
		else:
			my_lemons -= delta*50
	else:
		my_lemons = real_lemons
		is_active=false
	var int_score = int(my_lemons) 
	
	# put a 0 in front of single-digit numbers
	if int_score < 10:
		int_score = str("0",int_score)
	
	# blit that score!
	set_text(str(int_score))
	
	
func _ready():
	set_process(true)
	

func _process(delta):
	if is_active:
		_draw_score(delta)
	else:
		pass
	#print(my_score)

func _activate():
	is_active=true


