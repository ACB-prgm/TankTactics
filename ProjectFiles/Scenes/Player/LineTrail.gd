extends Line2D


onready var parent = get_parent()
onready var tween = $Tween

var last_parent_pos: Vector2
var MAX_POINTS := 10
var frame := 0


func _ready():
	set_physics_process(false)


func _physics_process(_delta):
	if !parent or !is_instance_valid(parent):
		# just free the line, the position will be handled by its parent
		set_physics_process(false)
		tween.interpolate_property(self, "modulate:a", null, 0.0, 
		0.3, Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
	else:
		frame += 1
		
		if frame == 3:
			frame = 0
			draw_trail()


func reparent(world):
#	yield(get_tree().create_timer(0.01), "timeout")
	parent.call_deferred("remove_child", self)
	world.call_deferred("add_child", self)


func draw_trail():
	add_point(to_local(parent.global_position), 0)
	
	if get_point_count() > MAX_POINTS:
		if points[MAX_POINTS] - points[0] == Vector2(0,0):
			set_physics_process(false)
		
		remove_point(MAX_POINTS)


func _on_Tween_tween_all_completed():
	queue_free()
