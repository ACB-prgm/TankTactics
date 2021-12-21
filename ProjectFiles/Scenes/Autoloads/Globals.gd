extends Node


const TILE_ANIM_TIME := 3.5

var player
var camera
var _2DWorld



# FUNCTIONS ————————————————————————————————————————————————————————————————————
func _ready():
	OS.center_window()
#	load_data()


# SAVE/LOAD
#const SAVE_DIR = 'user://saves/'
#
#var save_path = SAVE_DIR + 'save.dat'
#
#
#func save_data():
#	var dir = Directory.new()
#	if !dir.dir_exists(SAVE_DIR):
#		dir.make_dir_recursive(SAVE_DIR)
#
#	var file = File.new()
#	var error = file.open_encrypted_with_pass(save_path, File.WRITE, 'abigail')
#	if error == OK:
#		var data = {
#			"high_score" : high_score,
#			"shoot_on_aim" : shoot_on_aim,
#			"layout_preset" : layout_preset
#		}
#
#		file.store_var(data)
#		file.close()
#
#func load_data():
#	var file = File.new()
#	if file.file_exists(save_path):
#		var error = file.open_encrypted_with_pass(save_path, File.READ, 'abigail')
#		if error == OK:
#			var data = file.get_var()
#
#			high_score = data.get("high_score")
#			shoot_on_aim = data.get("shoot_on_aim")
#			layout_preset = data.get("layout_preset")
#
#			file.close()
