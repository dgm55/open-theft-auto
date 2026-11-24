extends "res://scripts/game.gd"

var failures: Array[String] = []


func _ready() -> void:
	super._ready()
	set_process(false)
	SaveGame.set_process(false)
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _run() -> void:
	_on_start()
	await get_tree().process_frame

	var pet := capybara_pet
	_expect(is_instance_valid(pet), "Starting a game did not spawn the capybara pet")
	if not is_instance_valid(pet):
		_report_results(0)
		return
	_expect(pet.visible, "The capybara is hidden at the on-foot spawn point")
	_expect(pet.get_child_count() >= 10, "The capybara procedural model is incomplete")
	pet.position = player_pos + Vector3(30.0, 0.0, 30.0)
	pet.follow(world, player_pos, player_yaw, 0.1)
	_expect(pet.position.distance_to(player_pos) < 24.0,
		"The capybara did not catch up when it fell too far behind")
	_expect(absf(pet.position.y - world.surface_height(pet.position.x, pet.position.z)) < 0.1,
		"The capybara did not follow the walkable surface height")

	_report_results(pet.get_child_count())


func _report_results(model_parts: int) -> void:
	AudioFX.stop_ambient()
	if failures.is_empty():
		print("CAPYBARA_PET_AUDIT_OK parts=%d" % model_parts)
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)
