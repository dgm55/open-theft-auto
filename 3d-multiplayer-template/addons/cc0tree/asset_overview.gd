@tool
extends Node3D
## CC0Tree Asset Overview: a grid of every model, each with its name underneath.
## Press Tab to go to the turntable (showcase.tscn).
##
## The grid is saved in the scene, so you can see it in the editor and select, move or delete any model or name.
## Added new models to res://addons/cc0tree/models, or changed the grid numbers below? Select the root node (AssetOverview)
## and press "Rebuild grid" in the Inspector. That re-creates the grid from the models folder.

const SHOWCASE_SCENE := "res://addons/cc0tree/showcase.tscn"

@export_tool_button("Rebuild grid", "Reload") var rebuild_button := rebuild_grid
## Same as the button above: tick this box in the editor to rebuild the grid. It un-ticks itself when done.
@export var rebuild_now := false:
	set(value):
		if value and Engine.is_editor_hint() and is_inside_tree():
			rebuild_grid.call_deferred()
		rebuild_now = false

@export_group("Models")
## Every model is scaled so its largest side is about this big.
@export var fit_size := 1.6

@export_group("Grid")
@export var grid_columns := 7
## Distance between columns.
@export var grid_spacing := 3.1
## Distance between rows. Bigger numbers leave more room for the name under each model.
@export var grid_row_spacing := 3.3

@export_group("Labels")
@export var label_font_size := 48
@export var label_pixel_size := 0.0066
## Longer names wrap onto a second line after this many pixels.
@export var label_wrap_width := 400
## Where the name sits relative to the bottom center of each model (small Z keeps it tight under the model).
@export var label_offset := Vector3(0, -0.02, 0.35)

@export_group("Camera")
## The grid uses a flat (orthographic) camera so every cell has exactly the same size and spacing.
## How steeply the camera looks down: 90 is straight down, lower shows more of the models' sides.
@export var pitch_degrees := 52.0
## Extra empty space around the grid, in world units.
@export var margin := 2.2

@onready var _grid_root: Node3D = $GridRoot
@onready var _camera: Camera3D = $Camera3D
@onready var _count_label: Label = $UI/CountLabel


func _ready() -> void:
	if _grid_root.get_child_count() == 0:
		rebuild_grid()
	else:
		_apply_looks()
		_update_camera()
	if not Engine.is_editor_hint():
		_count_label.text = "%d models" % _grid_root.get_child_count()
		get_viewport().size_changed.connect(_update_camera)


## Re-creates the grid from whatever is in res://addons/cc0tree/models.
func rebuild_grid() -> void:
	var scene_root: Node = get_tree().edited_scene_root if Engine.is_editor_hint() else self
	if scene_root == null:
		scene_root = self
	for child in _grid_root.get_children():
		_grid_root.remove_child(child)
		child.queue_free()
	var paths := ModelLibrary.find_models()
	for i in paths.size():
		var model := ModelLibrary.load_model(paths[i], fit_size)
		if model == null:
			continue
		var pretty := ModelLibrary.pretty_name(paths[i])
		var cell := Node3D.new()
		cell.name = pretty.replace(" ", "")
		cell.position = Vector3((i % grid_columns) * grid_spacing, 0, (i / grid_columns) * grid_row_spacing)
		_grid_root.add_child(cell)
		cell.owner = scene_root
		cell.add_child(model)
		model.owner = scene_root
		var label := Label3D.new()
		label.name = "Name"
		label.text = pretty
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.pixel_size = label_pixel_size
		label.font_size = label_font_size
		label.outline_size = 10
		label.width = label_wrap_width
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.position = label_offset
		label.no_depth_test = true
		cell.add_child(label)
		label.owner = scene_root
	# Center the whole grid on the origin.
	var rows := ceili(float(paths.size()) / grid_columns)
	_grid_root.position = Vector3(-(grid_columns - 1) * grid_spacing / 2.0, 0, -(rows - 1) * grid_row_spacing / 2.0)
	_count_label.text = "%d models" % paths.size()
	_update_camera()


## The slight brightening of dark models is applied when the scene loads (it is not saved in the scene file).
func _apply_looks() -> void:
	for cell in _grid_root.get_children():
		for child in cell.get_children():
			if child is Node3D and not child is Label3D:
				ModelLibrary.apply_look(child)


func _update_camera() -> void:
	if _camera == null:
		return
	var count := _grid_root.get_child_count()
	var rows := maxi(ceili(float(count) / grid_columns), 1)
	var pitch := deg_to_rad(pitch_degrees)
	var aspect := get_viewport().get_visible_rect().size.aspect()
	if aspect <= 0.0:
		aspect = 16.0 / 9.0
	var grid_width := (grid_columns - 1) * grid_spacing + margin * 2.0 + 2.0
	var grid_height := (rows - 1) * grid_row_spacing * sin(pitch) + 4.6 + margin
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = maxf(grid_height, grid_width / aspect)
	_camera.position = Vector3(0, sin(pitch), cos(pitch)) * 40.0
	_camera.look_at(Vector3(0, 0.0, 0))


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if _key(event, KEY_TAB):
		get_tree().change_scene_to_file(SHOWCASE_SCENE)

func _key(event: InputEvent, keycode: Key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == keycode
