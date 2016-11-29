extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var to_rotate = 0
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_process(true)

func _process(delta):
	get_node("ui").set_size(get_viewport().get_rect().size)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION and Input.is_mouse_button_pressed(3):
		get_node("model").rotate_y(-event.relative_x/100.0)


func _on_logout():
	Globals.set("gj_username", "")
	Globals.set("gj_token", "")
	get_tree().change_scene("res://world/login_screen.tscn")

