extends Node


const PORT = 31419
const BINDING = "127.0.0.1"
const auth_server := "https://accounts.google.com/o/oauth2/v2/auth"
const token_req := "https://oauth2.googleapis.com/token"

var redirect_server = TCP_Server.new()
var redirect_uri = "http://%s:%s" % [BINDING, PORT]
var redir_err = redirect_server.listen(PORT, BINDING)
var token


func _ready():
	get_auth_code()


func _process(delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			set_process(false)
			var auth_code = request.split("&scope")[0].split("=")[1]
			get_token(auth_code)


func get_auth_code():
	var headers = [
		"client_id = 694582530887-sipt32jliecakrvo41l9b9g8ujfedk53.apps.googleusercontent.com&",
		"redirect_uri = %s&" % redirect_uri,
		"response_type = code&",
		"scope = https://www.googleapis.com/auth/youtube.readonly",
	]
	
	var url = auth_server + "?"
	for x in headers:
		x = x.replace(" ", "")
		url += x
	
# warning-ignore:return_value_discarded
	OS.shell_open(url) # Opens window for user authentication


func get_token(auth_code):
	 var headers = [
		"code = %s" % auth_code, 
		"client_id = 694582530887-sipt32jliecakrvo41l9b9g8ujfedk53.apps.googleusercontent.com&",
		"client_secret = your_client_secret&",  #### FIGURE OUT HOW TO LOAD THIS DYNAMICALLY AND SAFELY
		"redirect_uri = %s" % redirect_uri,
		"grant_type = authorization_code"
	]


# SAVE/LOAD
const SAVE_DIR = 'user://token/'
var save_path = SAVE_DIR + 'token.dat'


func save_data():
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, 'abigail')
	if error == OK:
		file.store_var(token)
		file.close()


func load_data():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, 'abigail')
		if error == OK:
			token = file.get_var()
			file.close()
