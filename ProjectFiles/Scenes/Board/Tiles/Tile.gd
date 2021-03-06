extends Control

const COLORS = {
	"RED" : Color(1,0,0,1),
	"BLUE" : Color(0,.72,1,1)
}
const LIGHT_MAX := 1.3


onready var sprite = $Sprite
onready var label = $Label
onready var light = $Sprite/Light2D
onready var tween = $Tween
onready var animationPlayer = $AnimationPlayer
onready var anim_time = Globals.TILE_ANIM_TIME

var coords = "A0" setget set_coords
var occupied = false
var fin_light := false
var position = Vector2.ZERO


func _ready():
	light.energy = 0
	rect_size = sprite.texture.get_size() * sprite.scale
	rect_min_size = rect_size
	$Sprite/Area2D.tile = self


func set_coords(new_val):
	coords = new_val
	label.text = new_val


func _on_tiles_set():
	position = $Sprite/Area2D.global_position


func show_light(show=true, color="BLUE"):
	tween.stop_all()
	if show:
		fin_light = true
		light.color = COLORS.get(color)
		
		tween.interpolate_property(light, "energy", light.energy, LIGHT_MAX, 
		anim_time * 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.start()
	else:
		tween.interpolate_property(light, "energy", light.energy, 0, 
		anim_time * 0.4, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.start()


func _on_Tween_tween_completed(_object, _key):
	if fin_light:
		fin_light = false
		tween.interpolate_property(light, "energy", light.energy, 0, 
		anim_time * 0.4, Tween.TRANS_SINE, Tween.EASE_OUT, anim_time * 0.2)
		tween.start()
