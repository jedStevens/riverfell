extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal selected

var character_id = null
var selected = false

func _ready():
	connect("input_event", self, "check_event")

func check_event(ev):
	if ev.type == InputEvent.MOUSE_BUTTON and Input.is_mouse_button_pressed(1):
		emit_signal("selected")

func create(id, character):
	character_id = id
	set_name(str(character_id))
	get_node("HBoxContainer/name").set_text(character.name)
	
	var stats_str = str(character.purity) + ", "  + str(character.luck) + ", " + str(character.intimidation) + ", " + str(character.resistance)
	get_node("HBoxContainer/level").set_text(stats_str)

func toggle_selected():
	selected = not selected
	
	get_node("HBoxContainer/selected").set_pressed(selected)