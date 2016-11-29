extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var editable = false

signal create_character

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_enabled(editable)

func load_character(character):
	editable = true
	
	get_node("character_attributes/VBoxContainer/name/name_edit").set_text(character.name)
	
	get_node("character_attributes/VBoxContainer/purity/purity_slr").set_value(character.purity)
	get_node("character_attributes/VBoxContainer/resistance/resistance_slr").set_value(character.resistance)
	get_node("character_attributes/VBoxContainer/luck/luck_slr").set_value(character.luck)
	get_node("character_attributes/VBoxContainer/intimidation/intimidation_slr").set_value(character.intimidation)
	

func set_enabled(b):
	set_ignore_mouse(not b)

func _on_confirmed():
	var character = {}
	character.name = get_node("character_attributes/VBoxContainer/name/name_edit").get_text()
	character.purity = get_node("character_attributes/VBoxContainer/purity/purity_slr").get_value()
	character.resistance = get_node("character_attributes/VBoxContainer/resistance/resistance_slr").get_value()
	character.luck = get_node("character_attributes/VBoxContainer/luck/luck_slr").get_value()
	character.intimidation = get_node("character_attributes/VBoxContainer/intimidation/intimidation_slr").get_value()
	emit_signal("create_character", character)

func _on_create_pressed():
	_on_confirmed()
