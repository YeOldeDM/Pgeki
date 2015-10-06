
extends Label

# member variables here, example:
# var a=2
# var b="textvar"

var my_score=0
var real_score=0

var is_active=false

func _draw_score(delta):
	real_score = get_node('/root/globals').SCORE

	if (int(my_score)!=real_score):
		if(my_score < real_score):
			my_score += delta*100
		else:
			my_score -= delta*100
	else:
		my_score = real_score
		is_active=false
	var int_score = int(my_score) 
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


