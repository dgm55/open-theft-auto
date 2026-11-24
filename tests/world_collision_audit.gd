extends Node
## Headless regression audit for the imported GMC map and playable world.

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _expect_open(world: CityWorld, x: float, z: float, label: String) -> void:
	var altitude := world.surface_height(x, z)
	if world.collides_at(x, z, 0.35, altitude):
		failures.append("%s blocked at (%.1f, %.1f)" % [label, x, z])


func _run() -> void:
	seed(1143)
	var world := CityWorld.new()
	add_child(world)
	world.generate()

	if world.map_roads.size() < 100:
		failures.append("OSM road network was not loaded")
	if world.buildings.size() < 10:
		failures.append("Map and gameplay building collisions were not generated")
	if not world.collides_at(24.6, -14.3, 0.4):
		failures.append("Mapped building footprint is missing its collision")

	var open_roads := 0
	for i in 100:
		var spawn := world.random_road_spawn()
		if not world.collides_at(spawn.x, spawn.z, 2.0):
			open_roads += 1
	if open_roads < 80:
		failures.append("Too few OSM traffic positions are clear (%d/100)" % open_roads)

	# The inland map remains walkable; deep water still blocks movement and the
	# airport field is a safe exception.
	_expect_open(world, 0.0, CityWorld.WORLD_HALF + 8.0, "mapped southern edge")
	if not world.collides_at(0.0, CityWorld.LAND_HALF + 14.0, 0.35, 0.0):
		failures.append("Deep water boundary is open")
	_expect_open(world, 80.0, CityWorld.WORLD_HALF + 20.0, "airport approach")

	for building in world.buildings:
		if float(building.w) > 220.0 or float(building.d) > 220.0:
			failures.append("Oversized collision at (%.1f, %.1f): %.1f x %.1f" \
				% [building.x, building.z, building.w, building.d])

	if failures.is_empty():
		print("WORLD_COLLISION_AUDIT_OK roads=%d buildings=%d" % [
			world.map_roads.size(), world.buildings.size(),
		])
		get_tree().quit(0)
	else:
		for message in failures.slice(0, 30):
			push_error(message)
		push_error("World collision audit failed: %d issue(s)" % failures.size())
		get_tree().quit(1)
