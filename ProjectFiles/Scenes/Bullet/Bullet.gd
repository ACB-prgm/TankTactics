extends Node2D


const dur := .75
const TRANS = Tween.TRANS_QUAD

onready var tween = $Tween
onready var sprite = $Sprite

var impact_TSCN = preload("res://Scenes/Bullet/BulletImpact.tscn")
var target : Vector2 = Vector2(450, 100)


func _ready():
	shoot()


func shoot():
	look_at(target)
	target = target - Vector2(25, 0).rotated(rotation)

	tween.interpolate_property(self, "global_position", global_position, target, 
	dur, TRANS, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "scale", scale, scale*1.25, 
	dur/2.0, TRANS,Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", scale*1.25, scale, 
	dur/2.0, TRANS,Tween.EASE_IN, dur/2.0)
	tween.interpolate_property(sprite, "scale", Vector2(0.2, 0.3), Vector2(0.3, 0.3), 
	dur/2.0, TRANS,Tween.EASE_OUT)
	tween.interpolate_property(sprite, "scale", Vector2(0.3, 0.3), Vector2(0.2, 0.3), 
	dur/2.0, TRANS,Tween.EASE_IN, dur/2.0)
	tween.interpolate_property(sprite, "position", Vector2(15, 0), Vector2.ZERO, 
	dur/2.0, TRANS,Tween.EASE_OUT)
	tween.interpolate_property(sprite, "position", Vector2.ZERO, Vector2(15, 0), 
	dur/2.0, TRANS,Tween.EASE_IN, dur/2.0)
	tween.start()


func _on_Tween_tween_all_completed():
	var impact = impact_TSCN.instance()
	impact.global_position = global_position + Vector2(30,10).rotated(rotation)
	get_parent().add_child(impact)
	
	queue_free()
