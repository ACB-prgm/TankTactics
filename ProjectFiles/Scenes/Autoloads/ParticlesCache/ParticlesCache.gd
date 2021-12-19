extends CanvasLayer


var frames := 0
signal particlesCached

var materials = [
	preload("res://Scenes/Autoloads/ParticlesCache/Materials/BackBullet.tres"),
	preload("res://Scenes/Autoloads/ParticlesCache/Materials/FlashBulletImpact.tres"),
	preload("res://Scenes/Autoloads/ParticlesCache/Materials/FrontBullet.tres"),
	preload("res://Scenes/Autoloads/ParticlesCache/Materials/LinesBulletImpact.tres"),
	preload("res://Scenes/Autoloads/ParticlesCache/Materials/SmokeBulletImpact.tres")
]


func _ready():
	for material in materials:
		var particles_instance = Particles2D.new()
		particles_instance.set_process_material(material)
		particles_instance.set_modulate(Color(1,1,1,0))
		particles_instance.set_one_shot(true)
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)


func _physics_process(_delta):
	if frames >= 3:
		set_physics_process(false)
		emit_signal("particlesCached")
	frames += 1
