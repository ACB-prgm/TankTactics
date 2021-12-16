extends CenterContainer


const TILE_SIZE = Vector2(150, 150)

onready var camera = $Camera2D
onready var tile_container = $Control

var window_size = Vector2(ProjectSettings.get("display/window/size/height"), ProjectSettings.get("display/window/size/width"))


func _ready():
	tile_container.spawn_tiles()
	yield(self, "resized")
	camera.global_position = rect_size / 2
	camera.zoom = tile_container.rect_size / (TILE_SIZE * 6)
