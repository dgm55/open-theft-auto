extends Node3D

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _run() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = Human.RAGDOLL_COLLISION_LAYER
	floor_body.collision_mask = 0
	floor_body.position.y = -0.05
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(12, 0.1, 12)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)

	var character := Human.build_model("peter")
	character.position.y = 0.05
	add_child(character)
	await get_tree().physics_frame

	var simulator := Human.start_ragdoll(character, Vector3(1, 0, 0))
	_check(simulator != null, "Ragdoll simulator was not created")
	if simulator != null:
		var physical_bones: Array[PhysicalBone3D] = []
		for child in simulator.get_children():
			if child is PhysicalBone3D:
				physical_bones.append(child)
		_check(physical_bones.size() >= 12, "Too few physical bones were resolved")
		_check(simulator.is_simulating_physics(), "Physical bones did not start simulating")
		for frame in 120:
			await get_tree().physics_frame
		var pelvis: PhysicalBone3D
		for physical_bone in physical_bones:
			if String(physical_bone.bone_name).to_lower().contains("pelvis"):
				pelvis = physical_bone
				break
		_check(pelvis != null, "Pelvis physical bone is missing")
		if pelvis != null:
			_check(pelvis.global_position.y > -0.2, "Pelvis fell through the ragdoll floor")
		Human.stop_ragdoll(character)
		await get_tree().process_frame
		_check(not character.has_meta("ragdoll_simulator"), "Ragdoll state was not cleared")

	if failures.is_empty():
		print("RAGDOLL_AUDIT_OK")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)