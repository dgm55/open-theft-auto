extends "res://scripts/game.gd"
var test_x := 0.0
var test_z := 0.0
var test_climb := 0.0
var test_sprint := false
var issues: Array[String] = []
var melee_calls := 0
func _move_x() -> float: return test_x
func _move_z() -> float: return test_z
func _updown() -> float: return test_climb
func _drive_accel() -> float: return test_z
func _sprint_held() -> bool: return test_sprint
func _perform_melee() -> void: melee_calls += 1
func _ready() -> void:
	super._ready()
	set_process(false)
	SaveGame.set_process(false)
	call_deferred("audit")
func expect(ok: bool, label: String) -> void:
	if not ok: issues.append(label)
func audit() -> void:
	player_pos = Vector3(112, 0, 20)
	cam_yaw = 0
	test_z = 0.4
	for i in 60: _update_on_foot(1.0/60.0)
	var slow_distance := 20.0-player_pos.z
	expect(slow_distance > 1.6 and slow_distance < 1.9, "Analog walk speed")
	player_pos = Vector3(112, 0, 20)
	_walk_vel = Vector2.ZERO
	test_z = 1
	for i in 60: _update_on_foot(1.0/60.0)
	var full_walk_distance := 20.0-player_pos.z
	expect(full_walk_distance > slow_distance*2, "Full stick fails to increase speed")
	player_pos = Vector3(112, 0, 20)
	_walk_vel = Vector2.ZERO
	test_sprint = true
	for i in 60: _update_on_foot(1.0/60.0)
	expect(20.0-player_pos.z > full_walk_distance*1.4, "Sprint fails to increase speed")
	test_sprint = false
	test_z = 0
	for i in 30: _update_on_foot(1.0/60.0)
	expect(_walk_vel.length() < 0.01, "Walking slides after release")
	var test_ground_y := world.surface_height(player_pos.x, player_pos.z)
	player_pos.y = test_ground_y + 3.0
	_foot_vy = 0
	_update_on_foot(1.0/60.0)
	expect(player_pos.y > test_ground_y + 2.9 and player_pos.y < test_ground_y + 3.0,
		"Ledge descent teleports")
	for i in 120: _update_on_foot(1.0/60.0)
	expect(absf(player_pos.y-world.surface_height(player_pos.x, player_pos.z)) < 0.02, "Ground landing")
	space_state = "moon"
	player_pos = Vector3(0, CityWorld.MOON_Y, 0)
	_foot_vy = 0
	test_z = 1
	for i in 30: _update_moon_walk(1.0/60.0)
	expect(player_pos.y >= world.moon_height(player_pos.x, player_pos.z), "Lunar walk under surface")
	test_z = 0
	for i in 180: _update_moon_walk(1.0/60.0)
	expect(absf(player_pos.y-world.moon_height(player_pos.x, player_pos.z)) < 0.01, "Lunar idle does not settle")
	var craft := _make_spacecraft(0, 0, 0)
	craft.leg = "moon"
	craft.phase = "moon_descent"
	craft.pos = Vector3(0, CityWorld.MOON_Y+3, 0)
	craft.vy = 0.0
	craft.speed = 0.0
	test_climb = -1
	for i in 240:
		_update_spacecraft(craft, 1.0/60.0)
		if craft.phase == "landed": break
	expect(craft.phase == "landed", "Spacecraft never lands")
	expect(absf(craft.pos.y-world.moon_height(craft.pos.x, craft.pos.z)) < 0.01, "Spacecraft penetrates terrain")
	_handle_pad_extra(JOY_BUTTON_RIGHT_STICK)
	expect(melee_calls == 1, "Right-stick click fails as the melee fallback")
	if issues.is_empty(): print("MOVEMENT_AUDIT_OK")
	else:
		for issue in issues: push_error(issue)
	get_tree().quit(0 if issues.is_empty() else 1)
