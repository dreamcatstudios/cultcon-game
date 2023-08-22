extends Spatial

var mesh_size
onready var viewport = $Viewport
onready var panel_face = $MeshInstance
onready var touch_area = $MeshInstance/Area


var is_mouse_held = false
var is_mouse_inside = false
