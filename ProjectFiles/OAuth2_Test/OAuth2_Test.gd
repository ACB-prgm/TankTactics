extends Node


const PORT := 31419
const BINDING := "127.0.0.1"
const client_secret := "e346e1ul0W0mdqyPgIwBXeJy"
const client_ID := "694582530887-sipt32jliecakrvo41l9b9g8ujfedk53.apps.googleusercontent.com"
const auth_server := "https://accounts.google.com/o/oauth2/v2/auth"
const token_req := "https://oauth2.googleapis.com/token"

var redirect_server := TCP_Server.new()
var redirect_uri := "http://%s:%s" % [BINDING, PORT]
var redir_err = redirect_server.listen(PORT, BINDING)
var token
var refresh_token



func _ready():
	load_tokens()
	
	if !is_token_valid(token):
		get_auth_code()


func _process(_delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			set_process(false)
			var auth_code = request.split("&scope")[0].split("=")[1]
			get_token_from_auth(auth_code)


func get_auth_code():
	
	var body_parts = [
		"client_id=%s" % client_ID,
		"redirect_uri=%s" % redirect_uri,
		"response_type=code",
		"scope=https://www.googleapis.com/auth/youtube.readonly",
	]
	
	var url = auth_server + "?" + PoolStringArray(body_parts).join("&")
	
# warning-ignore:return_value_discarded
	OS.shell_open(url) # Opens window for user authentication

func get_token_from_auth(auth_code):
	
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	headers = PoolStringArray(headers)
	
	var body_parts = [
		"code=%s" % auth_code, 
		"client_id=%s" % client_ID,
		"client_secret=%s" % client_secret,
		"redirect_uri=%s" % redirect_uri,
		"grant_type=authorization_code"
	]
	
	var body = PoolStringArray(body_parts).join("&")
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_new_token_http_request_completed")
	
	var error = http_request.request(token_req, headers, true, HTTPClient.METHOD_POST, body)

	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)

func _on_new_token_http_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8())
	
	token = response["access_token"]
	refresh_token = response["refresh_token"]
	
	save_tokens()


func refresh_token(refresh_token):
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	headers = PoolStringArray(headers)
	
	var body_parts = [
		"client_id=%s" % client_ID,
		"client_secret=%s" % client_secret,
		"refresh_token=%s" % refresh_token,
		"grant_type=refresh_token"
	]
	
	var body = PoolStringArray(body_parts).join("&")
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_token_refresh_request_completed")
	
	var error = http_request.request(token_req, headers, true, HTTPClient.METHOD_POST, body)

	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)

func _on_token_refresh_request_completed(_result, response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8())
	token = response["access_token"]
	save_tokens()


func is_token_valid(token) -> bool:
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	headers = PoolStringArray(headers)
	
	var body = "access_token=%s" % token
	
# warning-ignore:return_value_discarded
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_check_token_request_completed")
	
	var error = http_request.request(token_req + "info", headers, true, HTTPClient.METHOD_POST, body)

	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = yield(http_request, "request_completed")
	var expiration = parse_json(response[3].get_string_from_utf8()).get("expires_in")
	###### CHECK IF THIS WORKS!!!!!!! ##########
	
	if expiration and int(expiration) > 0:
		return true
	else:
		return false



func _on_check_token_request_completed(_result, response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8())


# SAVE/LOAD
const SAVE_DIR = 'user://token/'
var save_path = SAVE_DIR + 'token.dat'


func save_tokens():
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, 'abigail')
	if error == OK:
		var tokens = {
			"token" : token,
			"refresh_token" : refresh_token
		}
		file.store_var(tokens)
		file.close()


func load_tokens():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, 'abigail')
		if error == OK:
			var tokens = file.get_var()
			token = tokens.get("token")
			refresh_token = tokens.get("refresh_token")
			file.close()
