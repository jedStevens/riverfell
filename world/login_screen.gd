extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var GameJolt = null

var token_edit = null
var user_edit = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	GameJolt = get_node("GameJoltAPI")
	
	token_edit = get_node("Control/HBoxContainer/VBoxContainer/HSplitContainer2/token_edit")
	user_edit = get_node("Control/HBoxContainer/VBoxContainer/HSplitContainer/username_edit")
	
	var file = File.new()
	if file.file_exists("user://login_save.dat"):
		file.open("user://login_save.dat", file.READ)
		var content = file.get_as_text()
		file.close()
		
		var args = content.split(":")
		if args.size() < 2:
			print("Error in the saved username file, last login must have crashed")
		else:
			user_edit.set_text(args[0])
			token_edit.set_text(args[1])
		
		if args[0].length() > 0:
			get_node("Control/HBoxContainer/VBoxContainer/remember").set_pressed(true)
			
	
	set_process(true)

func _process(delta):
	get_node("Control").set_size(get_viewport().get_rect().size)


func _on_login_pressed():
	var token = token_edit.get_text()
	var username = user_edit.get_text()
	var res  =GameJolt.auth_user(token, username)
	
	get_node("AnimationPlayer").play("loading")



func _on_GameJoltAPI_api_authenticated( data_str ):
	var data = {}
	data.parse_json(data_str)
	var success = data["response"]["success"]
	
	if success == "true":
		get_node("AnimationPlayer").play("success")
		
		var token = token_edit.get_text()
		var username = user_edit.get_text()
		
		Globals.set("gj_token", token)
		Globals.set("gj_username", username)
		
		var file = File.new()
		file.open("user://login_save.dat", file.WRITE)
		
		if get_node("Control/HBoxContainer/VBoxContainer/remember").is_pressed():
			file.store_string(username+":"+token)
		else:
			file.store_string(":")
		
		file.close()
		
		var file = File.new()
		file.open("user://session.dat", file.WRITE)
		file.store_string(username+":"+token)
		file.close()
		
		get_tree().change_scene("res://character_menu.tscn")
		
	elif success == "false":
		get_node("AnimationPlayer").play("error")
		get_node("Control/error/label").set_text(data["response"]["message"])
