extends KinematicBody2D


onready var area = $Area2D
onready var tween = $Tween


func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	move()


func move():
	var locs = []
	for loc in area.get_overlapping_areas():
		var pos = loc.global_position
		if pos != global_position:
			locs.append(pos)
	
	locs.shuffle()
	var loc = locs[0]
	tween.interpolate_property(self, "global_position", global_position, loc, 
	1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
	tween.start()
	
	yield(tween, "tween_all_completed")
	move()
	
	
