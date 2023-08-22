extends KinematicBody
class_name MovementController

export var gravity_multiplier := 3.0

var direction := Vector3()
var input_axis := Vector2()
var velocity := Vector3()
var snap := Vector3()
var up_direction := Vector3.UP
var stop_on_slope := true
onready var floor_max_angle: float = deg2rad(45.0)

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
onready var gravity = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)

# Called every physics tick. 'delta' is constant
func _physics_process(delta) -> void:
	# Leave this function empty to prevent player movement
	pass

func direction_input() -> void:
	# Leave this function empty to prevent player movement
	pass

func accelerate(delta: float) -> void:
	# Leave this function empty to prevent player movement
	pass
