extends Node2D



onready var tween = $Tween
onready var light = $Light2D
onready var smoke_particles = $SmokeParticles
onready var lines_particles = $LinesParticles
onready var flash_particles = $FlashParticles
onready var damageArea = $DamageArea2D

signal bullet_dead



func _ready():
	tween.interpolate_property(light, "energy", 2.5, .45, 
	0.55 , Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.start()
	
	Globals.camera.shake(100, 0.5, 100)
	
	$AnimatedSprite.set_frame(0)
	$AnimatedSprite.play()
	
	


func _on_Particles2D_Plus_particles_cycle_finished():
	var enemy = damageArea.get_overlapping_bodies()
	if enemy:
		enemy = enemy[0]
		enemy.take_damage()
	
	emit_signal("bullet_dead")
	
	queue_free()
