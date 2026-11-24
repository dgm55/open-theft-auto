@tool
extends Node3D
## CC0Tree Showcase: the turntable.
## Shows one model at a time on a spinning pedestal. Press Tab for the grid of every model (asset_overview.tscn).
## Drop more .fbx / .glb / .gltf files (and their textures) into res://addons/cc0tree/models and they show up automatically.
##
## Everything you see (lights, camera, pedestal, labels, buttons) is a node in showcase.tscn,
## so you can move, recolor or restyle it in the editor. The numbers below show up in the Inspector.
##
## Controls
##   Left / Right ..... previous / next model
##   Space ............ pause or resume the turntable
##   Tab .............. switch to the grid of every model
##   Mouse drag ....... rotate the model
##   Mouse wheel ...... zoom

const OVERVIEW_SCENE := "res://addons/cc0tree/asset_overview.tscn"

@export_group("Models")
## Every model is scaled so its largest side is about this big.
@export var fit_size := 1.6
## Turntable speed in radians per second.
@export var spin_speed := 0.6

@export_group("Camera")
@export var fov := 40.0
@export var camera_height := 1.3
@export var look_at_point := Vector3(0, 0.65, 0)
@export var zoom_distance := 4.0
@export var zoom_min := 1.8
@export var zoom_max := 7.0
@export var zoom_step := 0.25

var _paths: Array[String] = []
var _index := 0
var _spinning := true
var _dragging := false

@onready var _pivot: Node3D = $ModelPivot            # Holds the current model so it spins around its own center.
@onready var _camera: Camera3D = $Camera3D
@onready var _name_label: Label = $UI/NameLabel
@onready var _count_label: Label = $UI/CountLabel
@onready var _prev_button: Button = $UI/PrevButton
@onready var _next_button: Button = $UI/NextButton


func _ready() -> void:
	_paths = ModelLibrary.find_models()
	_update_camera()
	if _paths.is_empty():
		_name_label.text = "No models found in " + ModelLibrary.MODELS_DIR
		return
	# In the editor this shows the first model as a preview (it is not saved in the scene).
	_show_model(0)
	if Engine.is_editor_hint():
		return
	_prev_button.pressed.connect(_step.bind(-1))
	_next_button.pressed.connect(_step.bind(1))


func _step(direction: int) -> void:
	if _paths.is_empty():
		return
	_show_model((_index + direction + _paths.size()) % _paths.size())


func _show_model(index: int) -> void:
	_index = index
	for child in _pivot.get_children():
		child.queue_free()
	var model := ModelLibrary.load_model(_paths[_index], fit_size)
	if model != null:
		_pivot.add_child(model)
	_pivot.rotation = Vector3.ZERO
	_name_label.text = ModelLibrary.pretty_name(_paths[_index])
	_count_label.text = "%d / %d" % [_index + 1, _paths.size()]


func _update_camera() -> void:
	_camera.fov = fov
	_camera.position = Vector3(0, camera_height, zoom_distance)
	_camera.look_at(look_at_point)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _spinning and not _dragging:
		_pivot.rotate_y(spin_speed * delta)


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if _key(event, KEY_RIGHT):
		_step(1)
	elif _key(event, KEY_LEFT):
		_step(-1)
	elif _key(event, KEY_SPACE):
		_spinning = not _spinning
	elif _key(event, KEY_TAB):
		get_tree().change_scene_to_file(OVERVIEW_SCENE)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_dragging = mb.pressed
		elif mb.pressed:
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_distance = clampf(zoom_distance - zoom_step, zoom_min, zoom_max)
				_update_camera()
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_distance = clampf(zoom_distance + zoom_step, zoom_min, zoom_max)
				_update_camera()
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		_pivot.rotate_y(motion.relative.x * 0.01)

func _key(event: InputEvent, keycode: Key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == keycode
