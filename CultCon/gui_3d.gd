extends Spatial

# The size of the quad mesh itself.
var quad_mesh_size
# Used for checking if the mouse is inside the Area
var is_mouse_inside = false
# Used for checking if the mouse was pressed inside the Area
var is_mouse_held = false
# The last non-empty mouse position. Used when dragging outside of the box.
var last_mouse_pos3D = null
# The last processed input touch/mouse event. To calculate relative movement.
var last_mouse_pos2D = null

onready var node_viewport = $Viewport
onready var node_quad = $Quad
onready var node_area = $Quad/Area

# Questions and Question Manager Variables
var questions = [
	"ARE YOU READY?",
	"Are you having a nice day?",
	"Do you have many responsibilities?",
	"Look Around for a moment",
	"Are you familiar with your surroundings?",
	"Do you know where you are?",
	"Have you ever had a panic attack?",
	"Do you find yourself questioning your existence?",
	"Do you believe there is a God?",
	"Are you answering these questions out of free will?",
	"Are you certain?",
	"Do you feel comfortable in your room?",
	"If the light went out, would you be scared?",
	"Have you ever wondered when you will die?",
	"Do you have any enemies?",
	"If you suddenly went missing, would anybody come looking for you?",
	"Are you alone?",
	"If you screamed, would anybody hear?",
	"Do you know the person standing behind you?",
	'Are you alone?',
	"Relax take some time to relax"
]

var current_question_index = 0

# Typewriter effect variables
var current_char_index = 0
var typewriter_delay = 0.1
var typewriter_timer = Timer.new()

func _ready():
	node_area.connect("mouse_entered", self, "_mouse_entered_area")

	typewriter_timer.autostart = false
	typewriter_timer.connect("timeout", self, "_on_typewriter_timeout")
	add_child(typewriter_timer)

	display_current_question()

func _process(_delta):
	rotate_area_to_billboard()

func _mouse_entered_area():
	is_mouse_inside = true

func _unhandled_input(event):
	var is_mouse_event = false
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if event is mouse_event:
			is_mouse_event = true
			break

	if is_mouse_event and (is_mouse_inside or is_mouse_held):
		handle_mouse(event)
	elif not is_mouse_event:
		node_viewport.input(event)

func handle_mouse(event):
	quad_mesh_size = node_quad.mesh.size

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		is_mouse_held = event.pressed

	var mouse_pos3D = find_mouse(event.global_position)

	is_mouse_inside = mouse_pos3D != null
	if is_mouse_inside:
		mouse_pos3D = node_area.global_transform.affine_inverse() * mouse_pos3D
		last_mouse_pos3D = mouse_pos3D
	else:
		mouse_pos3D = last_mouse_pos3D
		if mouse_pos3D == null:
			mouse_pos3D = Vector3.ZERO

	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)

	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y

	mouse_pos2D.x = mouse_pos2D.x * node_viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * node_viewport.size.y

	event.position = mouse_pos2D
	event.global_position = mouse_pos2D

	if event is InputEventMouseMotion:
		if last_mouse_pos2D == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2D - last_mouse_pos2D
	last_mouse_pos2D = mouse_pos2D

	node_viewport.input(event)

func find_mouse(global_position):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(global_position)
	var dist = find_further_distance_to(camera.transform.origin)
	var to = from + camera.project_ray_normal(global_position) * dist

	var result = get_world().direct_space_state.intersect_ray(from, to, [], node_area.collision_layer, false, true)

	if result.size() > 0:
		return result.position
	else:
		return null

func find_further_distance_to(origin):
	var edges = []
	edges.append(node_area.to_global(Vector3(quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(-quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(-quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))

	var far_dist = 0
	var temp_dist
	for edge in edges:
		temp_dist = origin.distance_to(edge)
		if temp_dist > far_dist:
			far_dist = temp_dist

	return far_dist

func rotate_area_to_billboard():
	var billboard_mode = node_quad.get_surface_material(0).params_billboard_mode

	if billboard_mode > 0:
		var camera = get_viewport().get_camera()
		var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
		look = node_area.translation + look

		if billboard_mode == 2:
			look = Vector3(look.x, 0, look.z)

		node_area.look_at(look, Vector3.UP)
		node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_Y:
				_on_yes_button_pressed()
			elif event.scancode == KEY_N:
				_on_no_button_pressed()

func display_current_question():
	var label = $Viewport/GUI/Panel/Label
	if current_question_index == 3:
		var question = questions[current_question_index]
		current_char_index = 0
		label.text = ""
		typewriter_effect(question)
		$Viewport/GUI/Panel/yes_button.visible = false
		$Viewport/GUI/Panel/no_button.visible = false
		$Viewport/GUI/Panel/yes_button.disabled = true
		$Viewport/GUI/Panel/no_button.disabled = true
		$LookAround.start()
	else:
		$Viewport/GUI/Panel/yes_button.visible = true
		$Viewport/GUI/Panel/no_button.visible = true
		$Viewport/GUI/Panel/yes_button.disabled = false
		$Viewport/GUI/Panel/no_button.disabled = false
		
	if current_question_index == 13:
		var question = questions[current_question_index]
		current_char_index = 0
		label.text = ""
		typewriter_effect(question)
		$"../../OmniLight".visible = false
		$"../../DoorSound".play()
		$"../../DoorAnimation".play("door_open")
	if current_question_index == 15:
		var question = questions[current_question_index]
		current_char_index = 0
		label.text = ""
		typewriter_effect(question)
		$"../../OmniLight".visible = true
	elif current_question_index < questions.size():
		var question = questions[current_question_index]
		current_char_index = 0
		label.text = ""
		typewriter_effect(question)
	else:
		print("All questions are answered!")
		$Viewport/GUI/Panel/AnimationPlayer.play("creepy")

func typewriter_effect(question):
	var label = $Viewport/GUI/Panel/Label
	if current_char_index < question.length():
		label.text += question[current_char_index]
		current_char_index += 1
		typewriter_timer.set_wait_time(typewriter_delay)
		typewriter_timer.start()
		print("Typing:", label.text)
		$Viewport/GUI/Panel/yes_button.disabled = true
		$Viewport/GUI/Panel/no_button.disabled = true
		$Viewport/GUI/Panel/yes_button.visible = false
		$Viewport/GUI/Panel/no_button.visible = false
	else:
		label.text = question	
		print("Typing done:", label.text)


func _on_typewriter_timeout():
	if current_question_index < questions.size():
		if current_char_index < questions[current_question_index].length():
			typewriter_effect(questions[current_question_index])
		else:
			typewriter_timer.stop()
			if current_question_index != 3:
				$Viewport/GUI/Panel/yes_button.disabled = false
				$Viewport/GUI/Panel/no_button.disabled = false
				$Viewport/GUI/Panel/yes_button.visible = true
				$Viewport/GUI/Panel/no_button.visible = true
	else:
		typewriter_timer.stop()
		print("All questions are answered!")


func _on_yes_button_pressed():
	$"../../CanvasLayer/Label".visible = false
	if current_question_index == 3:
		print("TEST")
	elif $Viewport/GUI/Panel/yes_button.disabled == true:
		print("DISABLED")
	else:
		print("YES PRESSED")
		$beep.play()
		$blink.play("yes")



func _on_no_button_pressed():
	$"../../CanvasLayer/Label".visible = false
	if current_question_index == 3:
		print("TEST")
	elif $Viewport/GUI/Panel/no_button.disabled == true:
		print("DISABLED")
	else:
		print("NO PRESSED")
		$beep.play()
		$blink.play("no")


func change_question():
	current_question_index += 1
	display_current_question()

func _on_LookAround_timeout():
	current_question_index += 1
	display_current_question()
