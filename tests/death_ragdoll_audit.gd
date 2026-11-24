extends Node3D

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run_death_cycle")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _run_death_cycle() -> void:
	var game_script := load("res://scripts/game.gd") as GDScript
	_check(game_script != null, "Main game script did not load")
	if game_script == null:
		get_tree().quit(1)
		return
	var game := game_script.new() as Node
	add_child(game)
	await get_tree().process_frame
	game.set_process(false)
	SaveGame.set_process(false)
	var world := game.get("world") as CityWorld
	_check(world != null, "Death test world did not initialize")
	if world == null:
		game.queue_free()
		get_tree().quit(1)
		return
	var spawn := world.find_safe_spawn()
	var death_position := Vector3(
		float(spawn.x),
		world.surface_height(float(spawn.x), float(spawn.y)),
		float(spawn.y))
	game.set("player_pos", death_position)
	var player_node := game.get("player_node") as Node3D
	player_node.position = death_position
	game.call("_die")

	_check(GameState.paused, "Death did not pause gameplay")
	_check(player_node.has_meta("ragdoll_simulator"), "Death did not attach ragdoll state")
	_check(is_instance_valid(game.get("_ragdoll_collision_proxy")), "Death did not create local collision support")
	var simulator := player_node.get_meta("ragdoll_simulator", null) as PhysicalBoneSimulator3D
	_check(is_instance_valid(simulator) and simulator.is_simulating_physics(), "Death ragdoll is not simulating")

	for frame in 90:
		await get_tree().physics_frame

	var pelvis: PhysicalBone3D
	for child in simulator.get_children() if is_instance_valid(simulator) else []:
		if child is PhysicalBone3D and String(child.bone_name).to_lower().contains("pelvis"):
			pelvis = child
			break
	_check(pelvis != null, "Ragdoll pelvis body is missing")
	if pelvis != null:
		_check(pelvis.global_position.y > -0.3, "Ragdoll pelvis fell through local floor support")
		_check(pelvis.global_position.distance_to(death_position) > 0.05, "Ragdoll pelvis did not move under physics")

	game.call("_respawn")
	await get_tree().physics_frame
	_check(not GameState.paused, "Respawn left gameplay paused")
	_check(player_node.visible, "Respawn left player hidden")
	_check(not player_node.has_meta("ragdoll_simulator"), "Respawn did not clear ragdoll state")
	_check(game.get("_ragdoll_collision_proxy") == null, "Respawn did not clear temporary colliders")
	var respawn_position: Vector3 = game.get("player_pos")
	_check(player_node.position.distance_to(respawn_position) < 0.01, "Respawn did not reposition the player rig")
	_check((game.get("_walk_vel") as Vector2).is_zero_approx() and is_zero_approx(float(game.get("_foot_vy"))), "Respawn retained momentum")
	game.queue_free()

	if failures.is_empty():
		print("DEATH_RAGDOLL_AUDIT_OK")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)
