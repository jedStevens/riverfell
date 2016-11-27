extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)
	set_fixed_process(true)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION and Input.is_mouse_button_pressed(3):
		get_node("camera_mount").rotate_y(-event.relative_x/100.0)
		
