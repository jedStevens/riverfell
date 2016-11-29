extends Control

var GameJolt = null

var characters = {}

var ID = 1

var current = null

func _ready():
	GameJolt = get_node("../../../GameJoltAPI")
	
	
	var file = File.new()
	if file.file_exists("user://session.dat"):
		file.open("user://session.dat", file.READ)
		var content = file.get_as_text()
		file.close()
		
		var args = content.split(":")
		if args.size() < 2:
			print("Error in the saved username file, no authorized user, GJAPI is disabled")
		else:
			GameJolt.username_cache = args[0]
			GameJolt.token_cache = args[1]
	
	GameJolt.data_store_fetch_for_user("characters")

func _on_new_char_pressed():
	
	var character = {}
	character.name = "New Character"
	character.luck = 5
	character.resistance = 5
	character.intimidation= 5
	character.purity = 5
	
	get_node("../../character_edit_panel").load_character(character)

func item_selected(item):
	if current != null:
		get_node("HBoxContainer/Panel/ScrollContainer/characters").get_node(str(current)).toggle_selected()
	get_node("HBoxContainer/Panel/ScrollContainer/characters").get_node(str(item.character_id)).toggle_selected()
	# Lol have fun with this math later,
	
	#its to get around the 0 == false in the if statement
	#so i pre-increment the id
	#but then thats too many children for the list
	#so i decrement there
	
	current = item.character_id
	get_node("HBoxContainer/play_btn").set_disabled(false)

func _on_character_edit_panel_create_character(character):
	var node = preload("res://character_item.tscn").instance()
	node.connect("selected", self, "item_selected", [node])
	ID += 1
	characters[str(ID)] = character
	node.create(ID, character)
	get_node("HBoxContainer/Panel/ScrollContainer/characters").add_child(node)
	
	var out_str = ""
	for i in characters:
		var c = characters[i]
		out_str += c.name+":"+str(c.purity)+":"+str(c.luck)+":"+str(c.intimidation)+":"+str(c.resistance)+"[and]"
	GameJolt.data_store_set_for_user("characters", out_str)
	print("Wrote to GJ")

func _on_delete_char_pressed():
	characters.erase(str(current))
	var node = get_node("HBoxContainer/Panel/ScrollContainer/characters").get_node(str(current))
	get_node("HBoxContainer/Panel/ScrollContainer/characters").remove_child(node)
	
	current = null
	get_node("HBoxContainer/play_btn").set_disabled(true)


func _on_play_btn_pressed():
	Globals.set("game_character", characters[str(current)])
	get_tree().change_scene("res://world/test-scene.tscn")

func _on_GameJoltAPI_api_data_fetched( itemdata ):
	if itemdata.begins_with("FAILURE"):
		GameJolt.data_store_set("characters", [])
		return
	for c in itemdata.split("\n")[1].split("[and]"):
		var args = c.split(":")
		if args.size() < 5:
			continue
		var character = {}
		character.name = args[0]
		character.purity = args[1]
		character.luck = args[2]
		character.intimidation = args[3]
		character.resistance = args[4]
		
		var node = preload("res://character_item.tscn").instance()
		node.connect("selected", self, "item_selected", [node])
		ID += 1
		characters[str(ID)] = character
		node.create(ID, character)
		get_node("HBoxContainer/Panel/ScrollContainer/characters").add_child(node)
