extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# Character Stats 0 to 10
var purity = 0       # impure  -> pure (of heart, used for good vs evil spells)
var luck = 0         # unlucky -> lucky (used as a dummy point bar)
var intimidation = 0 # scarable -> scary (for spells vs other heroes)
var resistence = 0   # sickly -> immune (for forces of nature, such as poison or disease)

# Battle Stats 0 to 10
var strength = 0
var dexterity = 0
var intelligence = 0

var base_hit_points = 100
var base_mana_points = 100
var base_speed = 100

var velocity = Vector3(0,0,0)
var direction = Vector3(0,0,0)

var to = Vector3(0,0,0)
var from = Vector3(0,0,0)

var walk_to = false
var queue = false

var points = []

var eps = 0.8
var speed = 5.6
var turn_rate = 20
var target = null

var actions = []

var camera

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)
	
	get_node("human_male/AnimationPlayer").set_default_blend_time(0.2)
	
	camera = get_node("../camera_mount/Camera")
	
func lock_to_nav():
	set_translation(get_node("../world").get_closest_point(get_translation()))

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and Input.is_mouse_button_pressed(2):
		from = get_node("../camera_mount/Camera").project_ray_origin(event.pos)
		to = from + get_node("../camera_mount/Camera").project_ray_normal(event.pos)*1000
		if Input.is_key_pressed(KEY_SHIFT):
			queue = true
		walk_to = true
	
	if Input.is_action_just_pressed("player_stop"):
		stop()

func _fixed_process(delta):
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space())
	if(walk_to):
		var col = ds.intersect_ray(from, to)
		
		if("collider" in col.keys()):
			var obj = col["collider"]
			var colpos = col["position"]
			print(colpos)
			if queue and points.size() > 0:
				queue_walk_to(colpos)
			else:
				set_walk_to(colpos)
			
			walk_to = false
			queue = false
	
	if points.size() > 0:
		var distance = points[0] - get_translation()
		
		var old_dir = direction
		var new_dir = distance.normalized()
		var steer = new_dir - old_dir
		if steer.length() > 1:
			steer = steer.normalized()
		direction += steer * turn_rate * delta # direction of movement
		
		direction = direction.normalized()
		
		old_dir.y = 0
		new_dir.y = 0
		
		if distance.length() > eps:
			velocity =  direction*speed
		else:
			points.remove(0)
		
		get_node("human_male").set_rotation(Vector3(0, atan2(velocity.x, velocity.z), 0))
	else:
		if get_node("human_male/AnimationPlayer").get_current_animation() != "Idle-M-loop":
			get_node("human_male/AnimationPlayer").play("Idle-M-loop")
		velocity = Vector3(0,0,0)
	
	var motion = move(velocity * delta)
	
	if is_colliding():
		var n = get_collision_normal()
		motion = move(n.slide(motion))
		
		print("Moved: ", motion.length())
	
	get_node("../camera_mount").set_translation(get_translation())
	lock_to_nav()
	
	if target != null:
		get_node("../marker").set_translation(target)

func set_walk_to(pos):
	target = pos
	var source =  get_node("../world").get_closest_point(get_translation())
	points = get_node("../world").get_simple_path(source, target, true)
	print("Points: ", points.size())
	
	if get_node("human_male/AnimationPlayer").get_current_animation() != "Run-M-loop":
		get_node("human_male/AnimationPlayer").play("Run-M-loop")
	
	for p in points:
		var node = TestCube.new()
		node.set_translation(p)
		node.set_scale(Vector3(eps,eps,eps))
func queue_walk_to(pos):
	for p in get_node("../world").get_simple_path(points[points.size()-1], pos, true):
		points.append(p)

func stop():
	points = []