extends Node



var SCORE=0
var LEMONS =0

var LIFE=12
var MAX_LIFE=12


func blink(owner):

	if owner.blinker:
		owner.blink_timer += 1
		if owner.blink_timer > owner.blink_freq1:
			owner.get_node('sprite').set_modulate( Color( 1.0,1.0,1.0, 0.0 ) )
			owner.blink_timer = 0
			owner.blinker = false
	else:
		owner.blink_timer += 1
		if owner.blink_timer > owner.blink_freq2:
			owner.get_node('sprite').set_modulate( Color( 1.0,1.0,1.0, 1.0 ) )
			owner.blink_timer = 0
			owner.blinker = true

