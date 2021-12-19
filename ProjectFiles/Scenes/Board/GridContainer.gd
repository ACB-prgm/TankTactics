extends Control


const TILE_SIZE = Vector2(150, 150)
const ALPHABET = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

export var grid_size = 7

var tile_TSCN = preload("res://Scenes/Board/Tiles/Tile.tscn")

onready var camera = $Camera2D
onready var optionsContainer = $OptionsContainer
onready var tile_container = $GridContainer
onready var H_Labels = $HBoxContainer
onready var V_Labels = $VBoxContainer

var font = preload("res://Fonts/Font.tres")
var player_TSCN = preload("res://Scenes/Player_1/Player.tscn")
var players := {
	"ACB_Gamez" : null,
	"Subscriber" : null
}
var current_player
var tiles := {}
var current_moves : Dictionary
var current_shots : Dictionary

signal tiles_set


func _ready():
	randomize()
	spawn_tiles()
	camera.global_position = rect_size / 2
	camera.relative_zoom = tile_container.rect_size / (TILE_SIZE * 6)
	camera.zoom = camera.relative_zoom
	yield(get_tree().create_timer(0.001), "timeout") # JANKY, REQUIRED FOR TILES TO UPDATE POSITION
	start_game()


func start_game():
	emit_signal("tiles_set")
	
	for child in tile_container.get_children(): # CREATES DICTIONARY OF TILES AND NODES
		tiles[child.coords] = child
	
	spawn_players()


func spawn_tiles():
	tile_container.columns = grid_size
	for child in tile_container.get_children():
		child.free()
	
	for i in range(grid_size * grid_size):
		var tile_ins = tile_TSCN.instance()
# warning-ignore:return_value_discarded
		connect("tiles_set", tile_ins, "_on_tiles_set")
		tile_container.add_child(tile_ins)
		tile_ins.coords = "%s%s" % [ALPHABET[i % grid_size], i / grid_size]
	
	for i in range(grid_size):
		var h_label = Label.new()
		h_label.size_flags_horizontal = Control.SIZE_EXPAND
		h_label.text = ALPHABET[i]
		h_label.set("custom_fonts/font", font)
		H_Labels.add_child(h_label)
		
		var v_label = Label.new()
		v_label.size_flags_vertical = Control.SIZE_EXPAND
		v_label.text = str(i)
		v_label.set("custom_fonts/font", font)
		V_Labels.add_child(v_label)
		
	tile_container.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	V_Labels.rect_size.y = tile_container.rect_size.y
	V_Labels.rect_position = tile_container.rect_position - Vector2(V_Labels.rect_size.x*2, 0) + Vector2(0, TILE_SIZE.x/2 - 25 * .3)
	
	H_Labels.rect_size.x = tile_container.rect_size.x
	H_Labels.rect_position = tile_container.rect_position + Vector2(TILE_SIZE.x/2 - 25 * .3, H_Labels.rect_size.y + tile_container.rect_size.y)


func spawn_players():
	var available_tiles = tiles.keys()
	for player in players:
		available_tiles.shuffle()
		var spawn_tile = available_tiles[0]
		available_tiles.erase(spawn_tile)
		spawn_tile = tiles.get(spawn_tile)
		
		var player_ins = player_TSCN.instance()
		players[player] = player_ins
		player_ins.global_position = spawn_tile.position
		player_ins.player_name = player
		player_ins.connect("actions", self, "_on_recieved_player_actions")
		spawn_tile.occupied = player_ins
		add_child(player_ins)


func _on_recieved_player_actions(player, moves, shots):
	current_player = player
	current_moves = moves
	current_shots = shots
	
	for child in optionsContainer.get_children():
		child.queue_free()
	
	for move in moves:
		tiles.get(move).show_light()
		var button = Button.new()
		button.rect_scale *= 2
		button.text = "/move %s" % move
		button.connect("pressed", self, "_on_actionButton_pressed", [button])
		optionsContainer.add_child(button)
	for shot in shots:
		tiles.get(shot).show_light(true, "RED")
		var button = Button.new()
		button.rect_scale *= 2
		button.text = "/shoot %s" % shot
		button.connect("pressed", self, "_on_actionButton_pressed", [button])
		optionsContainer.add_child(button)


func _on_actionButton_pressed(button):
	var action = button.text.split(" ")
	for move in current_moves:
		tiles.get(move).show_light(false)
	for shot in current_shots:
		tiles.get(shot).show_light(false)
	
	match action[0]:
		"/move":
			var new_tile = tiles.get(action[1])
			var old_tile = tiles.get(current_player.current_tile)
			
			current_player.move(new_tile.position)
			current_player.current_tile = action[1]
			new_tile.occupied = current_player
			old_tile.occupied = false
			
		"/shoot":
			current_player.shoot()
