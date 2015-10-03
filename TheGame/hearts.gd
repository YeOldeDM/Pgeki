
extends Position2D

# member variables here, example:
# var a=2
# var b="textvar"




func _ready():
	pass

func _draw_hearts():
	var hearts = get_children()
	
	var life = get_node('/root/globals').LIFE
	var maxlife = get_node('/root/globals').MAX_LIFE
	var hearts_gone = ceil((maxlife-life)/4)
	print("HEARTS GONE  ",hearts_gone)
	var current_heart = (2 - hearts_gone)
	var sub_heart = life - (current_heart*4)
	print("CURRENT HEART  ",current_heart)
	print("SUB-HEART  ",sub_heart)
	for i in range(3):
		var heart = hearts[i]
		
		if i < current_heart:
			heart.set_frame(0)
		elif i > current_heart:
			heart.set_frame(4)
		elif i == current_heart:
			heart.set_frame((4-sub_heart))
		



