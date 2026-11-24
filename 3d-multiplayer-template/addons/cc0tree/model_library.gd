class_name ModelLibrary
## Shared helpers used by both scenes (showcase.tscn and asset_overview.tscn):
## finding the models in res://addons/cc0tree/models, loading one, scaling it to a standard size, and making its name readable.

const MODELS_DIR := "res://addons/cc0tree/models"
const MODEL_EXTENSIONS := ["fbx", "glb", "gltf"]

## Very dark models are hard to see on the dark background, so they get a slight glow added when shown.
## This only changes how they look in this project. The model files and textures are not touched.
## Add a file name (without .fbx) and an amount from 0 (none) to about 0.3 (a lot). Remove a line to turn it off.
const BRIGHTEN := {
	"SM_ComputerTower": 0.16,
	"SM_HandBomb": 0.15,
	"SM_Flashlight": 0.10,
	"SM_CombatKnife": 0.10,
	"SM_CrowBar": 0.08,
	"SM_DeadPineTree": 0.08,
}


## Every model file in res://addons/cc0tree/models, sorted by name.
static func find_models() -> Array[String]:
	var found: Array[String] = []
	var dir := DirAccess.open(MODELS_DIR)
	if dir == null:
		return found
	for file in dir.get_files():
		# Exported projects list imported files as "name.fbx.import" or "name.fbx.remap".
		var clean := file.trim_suffix(".import").trim_suffix(".remap")
		if clean.get_extension().to_lower() in MODEL_EXTENSIONS and not found.has(MODELS_DIR + "/" + clean):
			found.append(MODELS_DIR + "/" + clean)
	found.sort()
	return found


## Loads a model and scales it so its largest side is fit_size, with its base on y = 0 and centered on x / z.
static func load_model(path: String, fit_size: float) -> Node3D:
	var scene := load(path) as PackedScene
	if scene == null:
		return null
	var model := scene.instantiate() as Node3D
	if model == null:
		return null
	apply_look(model)
	var box := _combined_aabb(model, Transform3D.IDENTITY)
	var longest := maxf(box.size.x, maxf(box.size.y, box.size.z))
	if longest > 0.0:
		var s := fit_size / longest
		model.scale = Vector3.ONE * s
		var center := box.get_center()
		model.position = Vector3(-center.x * s, -box.position.y * s, -center.z * s)
	return model


## Applies the slight brightening from the BRIGHTEN table (matched by the model's file name) if this model is listed.
static func apply_look(model: Node) -> void:
	var lift: float = BRIGHTEN.get(model.scene_file_path.get_file().get_basename(), 0.0)
	if lift > 0.0:
		_brighten(model, lift)


## Adds a faint even glow to every material in the model so its darkest parts stay visible.
static func _brighten(node: Node, amount: float) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		for i in mesh_instance.get_surface_override_material_count():
			var source := mesh_instance.get_active_material(i) as StandardMaterial3D
			if source == null:
				continue
			var lifted := source.duplicate() as StandardMaterial3D
			lifted.emission_enabled = true
			lifted.emission = Color(amount, amount, amount * 1.1)
			lifted.emission_energy_multiplier = 1.0
			mesh_instance.set_surface_override_material(i, lifted)
	for child in node.get_children():
		_brighten(child, amount)


static func _combined_aabb(node: Node, parent_xform: Transform3D) -> AABB:
	var box := AABB()
	var has_box := false
	var xform := parent_xform
	if node is Node3D:
		xform = parent_xform * (node as Node3D).transform
	if node is MeshInstance3D:
		box = xform * (node as MeshInstance3D).get_aabb()
		has_box = true
	for child in node.get_children():
		var child_box := _combined_aabb(child, xform)
		if child_box.size != Vector3.ZERO:
			box = child_box if not has_box else box.merge(child_box)
			has_box = true
	return box


## "SM_Pine_Tree.fbx" -> "Pine Tree", "SM_AbstractZeusSculpture.fbx" -> "Abstract Zeus Sculpture".
static func pretty_name(path: String) -> String:
	var n := path.get_file().get_basename()
	if n.begins_with("SM_"):
		n = n.substr(3)
	n = n.replace("_", " ")
	var spaced := ""
	for i in n.length():
		var c := n[i]
		if i > 0 and c != c.to_lower() and n[i - 1] != " " and n[i - 1] == n[i - 1].to_lower() and not n[i - 1].is_valid_int():
			spaced += " "
		spaced += c
	return spaced
