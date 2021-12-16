extends Control


onready var sprite = $Sprite
onready var label = $Label

var coords = "A0" setget set_coords
var occupied = false
var position = Vector2.ZERO


func _ready():
	rect_size = sprite.texture.get_size() * sprite.scale
	rect_min_size = rect_size
	$Sprite/Area2D.tile = self


func set_coords(new_val):
	coords = new_val
	label.text = new_val


func _on_tiles_set():
	position = $Sprite/Area2D.global_position
