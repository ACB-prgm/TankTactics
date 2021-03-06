extends KinematicBody2D


const MOVE_TIME := 1.25
const ACCELERATION := 5

onready var barrelPos = $BarrellPosition2D
#onready var muzzleFlash = $BarrelPosition2D/MuzzleFlash
onready var movement_rangeArea = $MovementArea2D
onready var tween = $Tween
onready var lineTrails = $LineTrails.get_children()
onready var shader = $Sprite.get_material()
onready var trailsNode = $LineTrails
#onready var portalAnimatedSprite = $PortalAnimatedSprite

var bullet_TSCN = preload("res://Scenes/Bullet/Bullet.tscn")
var current_moves := {}
var current_shots := {}
var current_tile 
var player_name : String
var action_points := 1
var dead := false
var health = 3
var thrust := 0.0
var past_val = Vector2.ZERO

signal actions(player, moves, shots)
signal player_died(player)
signal player_action(is_acting)


func _ready():
	reparent_line_trails()
	Globals.player = self
	yield(get_tree().create_timer(.01), "timeout")
	for trail in lineTrails:
		trail.set_thrust(thrust)
	
	get_actions()


func reparent_line_trails():
	for trail in lineTrails:
		trail.reparent(get_parent())


func get_actions(emit=true):
	current_moves.clear()
	current_shots.clear()
	
	for tile in movement_rangeArea.get_overlapping_areas():
		tile = tile.tile
		if !tile.occupied and global_position.distance_to(tile.position) < 213:
			current_moves[tile.coords] = tile
		elif tile.occupied and tile.occupied != self:
			current_shots[tile.coords] = tile
		elif tile.occupied and tile.occupied == self:
			current_tile = tile
	if emit:
		emit_signal("actions", self, current_moves, current_shots)


func show_move_lights():
	get_actions(false)
	for move in current_moves:
		current_moves.get(move).show_light()
	for shot in current_shots:
		current_shots.get(shot).show_light(true, "RED")



func move(tile):
	if action_points > 0:
		emit_signal("player_action", true)
		action_points -= 1
		current_tile.occupied = false
		tile.occupied = self
		current_tile = tile
		
		var pos = tile.position
		var aim_rot = global_position.direction_to(pos).angle() + deg2rad(90)
		aim_rot = short_angle_dist(rotation, aim_rot) + rotation
		
		tween.interpolate_property(self, "rotation", rotation, aim_rot, 
		MOVE_TIME * 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		
		tween.interpolate_property(self, "global_position", global_position, pos, 
		MOVE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		
		yield(tween, "tween_all_completed")
		movement_rangeArea.rotation = rotation # ENSURES IS AT 90?? ANGLE RELATIVE TO BOARD
		thrust = 1
		emit_signal("player_action", false)
		
		get_actions()


func _on_Tween_tween_step(_object, key, _elapsed, value):
	if key == ":global_position":
		movement_rangeArea.rotation = rotation
			
		if past_val:
			thrust = clamp(value.distance_to(past_val)/2.0, 0.0, 1.0)
			for trail in lineTrails:
				trail.set_thrust(thrust)
		past_val = value


# SHOOT FUNCTIONS ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
func shoot(tile):
	if action_points > 0:
		emit_signal("player_action", true)
		action_points -= 1
		
		var aim_rot = global_position.direction_to(tile.position).angle() + deg2rad(90)
		var rot_time = clamp(abs(rad2deg(short_angle_dist(rotation, aim_rot))/100.0), 0.0, 2.0)
		
		aim_rot = short_angle_dist(rotation, aim_rot) + rotation
		
		tween.interpolate_property(self, "rotation", rotation, aim_rot, 
		rot_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		
		yield(tween, "tween_all_completed")
		yield(get_tree().create_timer(0.15), "timeout")
		
		var bullet_ins = bullet_TSCN.instance()
		bullet_ins.parent = self
		bullet_ins.start_pos = barrelPos.global_position
		bullet_ins.target = tile.position
		get_parent().add_child(bullet_ins)


func _on_bullet_dead():
	emit_signal("player_action", false)

# AIMING FUNCTIONS ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
func _lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference


# PORTAL FUNCTIONS (SPAWN AND DEATH) ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
#func portal(_in=true):
#	trailsNode.visible = !_in
#	set_physics_process(!_in)
#
#	var start_progress = 0.3
#	if _in:
#		start_progress = 1.0
#	else:
#		dead = true
#		thrusterAudio.volume_db = -40
#		set_physics_process(false)
#		scoreTimer.stop()
#
#	shader.set("shader_param/progress", start_progress)
#
#	if _in:
#		yield(Transitioner, "_in_finished")
#
#	tween.interpolate_property(shader, "shader_param/progress", 
#	start_progress, abs(start_progress - 1.0), 
#	start_progress, Tween.TRANS_QUAD, Tween.EASE_IN)
#
#	tween.start()


#func _on_Tween_tween_all_completed():
#	var _in = false
#	if shader.get("shader_param/progress") == 0.0:
#		scoreTimer.start()
#		_in = true
#		Globals.camera.shake(1000, 0.3, 1000, 8)
#
#	set_physics_process(_in)
#	trailsNode.visible = _in
#	portalAnimatedSprite.play("", !_in)
#
#	Globals.current_score_time = score_time

func _on_new_round():
	action_points += 1


func take_damage():
	health -= 1
	
	if health <= 0:
		die()


func die():
	if !dead:
		emit_signal("player_died", player_name)
		current_tile.occupied = false
		dead = true
		queue_free()
#		portal(false)
#		Transitioner.change_title_page("SCORE")
#		Music._out()
