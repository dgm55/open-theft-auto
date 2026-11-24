extends Node

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("run")


func check(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)


func run() -> void:
	seed(24680)
	var world := CityWorld.new()
	add_child(world)
	world.generate()

	var open_roads := 0
	for i in 100:
		var spawn := world.random_road_spawn()
		if not world.collides_at(spawn.x, spawn.z, 2.0):
			open_roads += 1
	check(open_roads >= 80, "OSM road traffic spawns are obstructed")
	check(world.collides_at(24.6, -14.3, 0.4), "Mapped building has no collision")
	check(world.terrain_height(600, -400) > 1, "Countryside has no relief")
	check(world.on_water(900, -200), "West/east sea classified as land")
	check(not world.on_water(172, 507), "Runway classified as water")
	check(absf(world.surface_height(300, -650)) < 0.01, "Launch pad not level")
	check(world.camera_clearance(Vector3(24.6, 2, -50),
		Vector3(24.6, 2, -5)).z < -14, "Camera passes through mapped building")
	check(world.swept_collision(Vector3(-10, 0, -14), Vector3(50, 0, -14), 0.4),
		"Fast motion tunnels through mapped building")

	var natural := world.get_node("NaturalCoastTerrain") as MeshInstance3D
	var arrays := natural.mesh.surface_get_arrays(0)
	for normal in arrays[Mesh.ARRAY_NORMAL]:
		if normal.y <= 0:
			failures.append("Terrain normal points below the surface")
			break

	if failures.is_empty():
		print("NATURAL_WORLD_AUDIT_OK roads=%d" % world.map_roads.size())
		get_tree().quit(0)
	else:
		for failure in failures.slice(0, 30):
			push_error(failure)
		get_tree().quit(1)
