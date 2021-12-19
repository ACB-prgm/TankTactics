extends Node2D



onready var tween = $Tween
onready var light = $Light2D
onready var smoke_particles = $SmokeParticles
onready var lines_particles = $LinesParticles
onready var flash_particles = $FlashParticles


func _ready():
	
	tween.interpolate_property(light, "energy", null, 0.2, 
	1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.start()
	
	$AnimatedSprite.set_frame(0)
	$AnimatedSprite.play()


func _on_Particles2D_Plus_particles_cycle_finished():
	print("hi")
	queue_free()
