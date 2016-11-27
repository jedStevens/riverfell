extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const MAX_CHARACTER_POINTS = 22

var editable = false
var is_valid = false

signal create_character

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_enabled(editable)
	set_process(true)
	get_node("ConfirmationDialog/VBoxContainer/cost/max_cost_lbl").set_text(" of max "+ str(MAX_CHARACTER_POINTS))
	get_node("ConfirmationDialog").set_hide_on_ok(false)

func _process(delta):
	var cost = get_cost()
	get_node("ConfirmationDialog/VBoxContainer/cost/cost_lbl").set_text(str(cost))
	if cost <= MAX_CHARACTER_POINTS:
		is_valid = true
		get_node("ConfirmationDialog").set_hide_on_ok(is_valid)
	else:
		is_valid= false
		get_node("ConfirmationDialog").set_hide_on_ok(is_valid)

func get_cost():
	var cost = 0
	cost += get_node("ConfirmationDialog/VBoxContainer/purity/purity_slr").get_value()
	cost += get_node("ConfirmationDialog/VBoxContainer/resistance/resistance_slr").get_value()
	cost += get_node("ConfirmationDialog/VBoxContainer/luck/luck_slr").get_value()
	cost += get_node("ConfirmationDialog/VBoxContainer/intimidation/intimidation_slr").get_value()
	return cost

func load_character(character):
	editable = true
	
	get_node("ConfirmationDialog/VBoxContainer/name/name_edit").set_text(character.name)
	
	get_node("ConfirmationDialog/VBoxContainer/purity/purity_slr").set_value(character.purity)
	get_node("ConfirmationDialog/VBoxContainer/resistance/resistance_slr").set_value(character.resistance)
	get_node("ConfirmationDialog/VBoxContainer/luck/luck_slr").set_value(character.luck)
	get_node("ConfirmationDialog/VBoxContainer/intimidation/intimidation_slr").set_value(character.intimidation)
	
	get_node("ConfirmationDialog").popup()

func set_enabled(b):
	set_ignore_mouse(not b)

func _on_confirmed():
	if is_valid:
		var character = {}
		character.name = get_node("ConfirmationDialog/VBoxContainer/name/name_edit").get_text()
		character.purity = get_node("ConfirmationDialog/VBoxContainer/purity/purity_slr").get_value()
		character.resistance = get_node("ConfirmationDialog/VBoxContainer/resistance/resistance_slr").get_value()
		character.luck = get_node("ConfirmationDialog/VBoxContainer/luck/luck_slr").get_value()
		character.intimidation = get_node("ConfirmationDialog/VBoxContainer/intimidation/intimidation_slr").get_value()
		emit_signal("create_character", character)