extends KinematicBody2D


const MAX_SPEED := 200
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
var action_points := 0
var dead := false
var moving := false
var health = 3
var look_dir : Vector2
var aim_dir : Vector2
var thrust := 0
var past_val = Vector2.ZERO

signal actions(player, moves, shots)

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


func get_actions():
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
	
	emit_signal("actions", self, current_moves, current_shots)


func show_move_lights():
	for move in current_moves:
		current_moves.get(move).show_light()
	for shot in current_shots:
		current_shots.get(shot).show_light(true, "RED")



func move(tile):
	current_tile.occupied = false
	tile.occupied = self
	current_tile = tile
	
	moving = true
	var pos = tile.position
	look_dir = global_position.direction_to(pos)
	tween.interpolate_property(self, "global_position", global_position, pos, 
	1.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	movement_rangeArea.rotation = rotation # ENSURES IS AT 90º ANGLE RELATIVE TO BOARD
	thrust = 1
	moving = false
	
	get_actions()


func _on_Tween_tween_step(_object, key, _elapsed, value):
	
	if key == ":global_position":
		movement_rangeArea.rotation = rotation
		
		if look_dir:
			var aim_rot = look_dir.angle() + deg2rad(90)
			rotation = _lerp_angle(rotation, aim_rot, 0.075)
			
		if past_val:
			thrust = clamp(value.distance_to(past_val)/2, 0, 1)
			for trail in lineTrails:
				trail.set_thrust(thrust)
		past_val = value


# SHOOT FUNCTIONS ——————————————————————————————————————————————————————————————
func shoot(tile):
	var aim_rot = global_position.direction_to(tile.position).angle() + deg2rad(90)
	aim_rot = short_angle_dist(rotation, aim_rot) + rotation
	
	tween.interpolate_property(self, "rotation", rotation, aim_rot, 
	.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.15), "timeout")
	
	var bullet_ins = bullet_TSCN.instance()
	bullet_ins.target = tile.position
	bullet_ins.global_position = barrelPos.global_position
	get_parent().add_child(bullet_ins)
#	get_parent().call_deferred("add_child", bullet_ins)

# AIMING FUNCTIONS —————————————————————————————————————————————————————————————
func _lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference


# PORTAL FUNCTIONS (SPAWN AND DEATH) ———————————————————————————————————————————
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


func take_damage():
	Globals.camera.shake(1000, 0.3, 1000, 8)
	health -= 1
	
	if health <= 0:
		die()

func die():
	if !dead:
		dead = true
#		portal(false)
#		Transitioner.change_title_page("SCORE")
#		Music._out()
