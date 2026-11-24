extends Node3D
var world: CityWorld
var output_dir := "user://visual-audit"
func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Visual audit requires a graphical renderer; run it with the Godot GUI executable.")
		get_tree().quit(1)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output_dir = arg.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(output_dir)
	seed(24680)
	world = CityWorld.new()
	add_child(world)
	world.generate()
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("7593b5")
	sky_material.sky_horizon_color = Color("b6c5ce")
	sky.sky_material = sky_material
	env.sky = sky
	env.background_color = Color(0.52, 0.69, 0.81)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.8, 0.9)
	env.ambient_light_energy = 0.35
	env.ssr_enabled = true
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.ssao_enabled = true
	environment.environment = env
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.shadow_enabled = true
	add_child(sun)
	var camera := Camera3D.new()
	camera.far = 6000
	camera.current = true
	add_child(camera)
	var street_midpoint := Vector2.ZERO
	var street_direction := Vector2.RIGHT
	var nearest_road_distance := INF
	for segment in world.map_roads:
		var road_from: Vector2 = segment.from
		var road_to: Vector2 = segment.to
		var midpoint := (road_from + road_to) * 0.5
		var distance := midpoint.length()
		if distance < nearest_road_distance and road_from.distance_to(road_to) > 5.0:
			nearest_road_distance = distance
			street_midpoint = midpoint
			street_direction = (road_to - road_from).normalized()
	var street_position := Vector3(
		street_midpoint.x - street_direction.x * 10.0,
		world.terrain_height(street_midpoint.x, street_midpoint.y) + 2.2,
		street_midpoint.y - street_direction.y * 10.0)
	var street_target := Vector3(
		street_midpoint.x + street_direction.x * 8.0,
		world.terrain_height(street_midpoint.x, street_midpoint.y) + 1.0,
		street_midpoint.y + street_direction.y * 8.0)
	var shots := [
		["city", Vector3(110, 65, 130), Vector3(0, 16, 0)],
		["coast", Vector3(950, 630, 1050), Vector3(0, 0, 40)],
		["street", street_position, street_target],
		["facade", Vector3(46, 5, 15), Vector3(32, 12, 34)],
		["moon", Vector3(90, 4045, 110), Vector3(0, 4000, 0)]]
	var village_center: Vector2 = world.gmc_village_center
	var village_height := world.terrain_height(village_center.x, village_center.y)
	shots.append([
		"village",
		Vector3(village_center.x + 28.0, village_height + 19.0, village_center.y + 32.0),
		Vector3(village_center.x, village_height + 2.0, village_center.y),
	])
	for shot in shots:
		env.background_mode = Environment.BG_COLOR if shot[0] == "moon" else Environment.BG_SKY
		env.background_color = Color(0.003, 0.004, 0.008) if shot[0] == "moon" else Color(0.52, 0.69, 0.81)
		camera.position = shot[1]
		camera.look_at(shot[2])
		await get_tree().process_frame
		RenderingServer.force_draw()
		var image := get_viewport().get_texture().get_image()
		if image == null:
			push_error("Could not capture visual audit image: %s" % shot[0])
			get_tree().quit(1)
			return
		var error := image.save_png(output_dir.path_join(shot[0] + ".png"))
		if error != OK:
			push_error("Could not save visual audit image %s: %s" % [
				shot[0], error_string(error),
			])
			get_tree().quit(1)
			return
	print("VISUAL_AUDIT_OK")
	get_tree().quit()
