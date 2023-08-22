extends Node


export var controller_path := NodePath("../")
onready var controller: MovementController = get_node(controller_path)

export var head_path := NodePath("../Head")
onready var cam: Camera = get_node(head_path).cam

export var sprint_speed := 16
export var fov_multiplier := 1.05

onready var normal_fov: float = cam.fov


# Called every physics tick. 'delta' is constant


func can_sprint() -> bool:
	return (controller.is_on_floor() and Input.is_action_pressed("sprint") 
			and controller.input_axis.x >= 0.5)
