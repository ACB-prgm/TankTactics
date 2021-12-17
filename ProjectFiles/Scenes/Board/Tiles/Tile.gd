extends Control

const COLORS = {
	"RED" : Color(1,0,0,1),
	"BLUE" : Color(0,.71,1,1)
}


onready var sprite = $Sprite
onready var label = $Label
onready var light = $Sprite/Light2D
onready var tween = $Tween
onready var animationPlayer = $AnimationPlayer

var coords = "A0" setget set_coords
var occupied = false
var position = Vector2.ZERO


func _ready():
	show_light(false)
	rect_size = sprite.texture.get_size() * sprite.scale
	rect_min_size = rect_size
	$Sprite/Area2D.tile = self


func set_coords(new_val):
	coords = new_val
	label.text = new_val


func _on_tiles_set():
	position = $Sprite/Area2D.global_position


func show_light(show=true, color="BLUE"):
	if show:
		light.color = COLORS.get(color)
		set_physics_process(true)
		animationPlayer.play("light")
	else:
		animationPlayer.stop()
		tween.interpolate_property(light, "energy", light.energy, 0, 
		1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.start()
		set_physics_process(false)
