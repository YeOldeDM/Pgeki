extends Node



var SCORE=0
var LEMONS =0

var LIFE=12
var MAX_LIFE=12


func blink(owner):
	"""
	#	HOW TO USE BLINK:	#
	Any object invoking blink() must have the following:
	-A sprite child (the one that is blinking) named exactly "sprite"
	
	The following variables defined in the top-level of the object's script:
	var blinker=false	#A switch for blinking on/off
	var blink_timer=0	#A timer for the blinker
	var blink_freq1=1	#an INT, how many frames the blink will stay 'off'
	var blink_freq2=1	#an INT, how many frames the blink will stay 'on'
	    Tweak freq1/2 to get different 'modulations' of blink patterns.
	"""

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

