extends Node

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _has_named_descendant(node: Node, target: String) -> bool:
	if node.name.contains(target):
		return true
	for child in node.get_children():
		if _has_named_descendant(child, target):
			return true
	return false


func _has_visible_imported_line(node: Node) -> bool:
	if node is GeometryInstance3D and node.name.ends_with("-lines") \
		and node.is_visible_in_tree():
		return true
	for child in node.get_children():
		if _has_visible_imported_line(child):
			return true
	return false


func _building_clear_of_water(
	world: CityWorld,
	building: Dictionary,
	extra_clearance := CityWorld.GMC_BUILDING_WATER_CLEARANCE
) -> bool:
	var center := Vector2(float(building.x), float(building.z))
	var footprint_radius := Vector2(float(building.w), float(building.d)).length() * 0.5
	for segment in world.map_water_segments:
		var a: Vector2 = segment.from
		var b: Vector2 = segment.to
		var direction := b - a
		if direction.length_squared() <= 0.0:
			continue
		var t := clampf((center - a).dot(direction) / direction.length_squared(), 0.0, 1.0)
		var nearest := a + direction * t
		var clearance := footprint_radius + float(segment.width) * 0.5 + extra_clearance
		if center.distance_to(nearest) < clearance:
			return false
	return true


func _run() -> void:
	var world := CityWorld.new()
	add_child(world)
	world.generate()

	var map := world.get_node_or_null("JuizDeForaMap") as Node3D
	_expect(map != null, "The imported GMC map scene is missing")
	if map != null:
		_expect(is_equal_approx(map.scale.x, CityWorld.GMC_MAP_SCALE),
			"The GMC map is not positioned at the expected gameplay scale")
		var expected_map_position := -CityWorld.GMC_MAP_CENTER * CityWorld.GMC_MAP_SCALE
		expected_map_position.y = world.terrain_height(0.0, 0.0)
		_expect(map.position.is_equal_approx(expected_map_position),
			"The GMC map is not aligned to the OSM projection origin")
		_expect(_has_named_descendant(map, "Roads"), "The map has no road layer")
		_expect(_has_named_descendant(map, "Buildings"), "The map has no building layer")
		_expect(not _has_visible_imported_line(map),
			"Imported GLB linework is still visible over the reconstructed map")

	_expect(world.map_roads.size() > 100, "OSM road network was not loaded")
	_expect(world.road_segments.size() == world.map_roads.size(),
		"The minimap/collision road index (%d) does not match the OSM road network (%d)" % [
			world.road_segments.size(), world.map_roads.size(),
		])
	var near_water_infill := 0
	var mapped_building_water_overlaps := 0
	for building in world.buildings:
		var kind := str(building.get("kind", ""))
		if kind in [
			"gmc_infill_house", "gmc_midrise", "suburb_house", "suburb_garage",
		] \
				and not _building_clear_of_water(world, building):
			near_water_infill += 1
		elif kind == "gmc_osm_building" \
				and not _building_clear_of_water(world, building, 0.0):
			mapped_building_water_overlaps += 1
	_expect(near_water_infill == 0,
		"%d inferred buildings intersect the mapped water setback" % near_water_infill)
	_expect(mapped_building_water_overlaps == 0,
		"%d mapped building footprints overlap visible OSM waterways" \
			% mapped_building_water_overlaps)
	var submerged_roads := 0
	for segment in world.map_roads:
		var midpoint: Vector2 = (segment.from + segment.to) * 0.5
		var road_height := world.surface_height(midpoint.x, midpoint.y)
		if not segment.get("bridge", false):
			road_height += 0.14
		if road_height <= world.water_surface_y(midpoint.x, midpoint.y):
			submerged_roads += 1
	_expect(submerged_roads == 0,
		"%d OSM road segments are below the playable shoreline" % submerged_roads)
	_expect(world.get_node_or_null("GMC OSM road surfaces") != null,
		"Visible OSM road surfaces were not generated")
	var road_surface := world.get_node_or_null("GMC OSM road surfaces") as MeshInstance3D
	if road_surface != null and road_surface.mesh != null \
			and road_surface.mesh.get_surface_count() > 0:
		var road_material := road_surface.material_override as StandardMaterial3D
		_expect(road_material != null and road_material.albedo_texture != null
			and road_material.albedo_texture.resource_path == "res://assets/textures/road.png",
			"OSM road surfaces are missing the asphalt texture")
		var road_arrays := road_surface.mesh.surface_get_arrays(0)
		var road_uvs: PackedVector2Array = road_arrays[Mesh.ARRAY_TEX_UV]
		_expect(not road_uvs.is_empty(), "OSM road surfaces have no tiled texture UVs")
	var sidewalk_surface := world.get_node_or_null("GMC OSM sidewalks") as MeshInstance3D
	if sidewalk_surface != null and sidewalk_surface.mesh != null \
			and sidewalk_surface.mesh.get_surface_count() > 0:
		var sidewalk_material := sidewalk_surface.material_override as StandardMaterial3D
		_expect(sidewalk_material != null and sidewalk_material.albedo_texture != null
			and sidewalk_material.albedo_texture.resource_path
				== "res://assets/textures/footpath.png",
			"OSM sidewalks are missing the footpath texture")
		var sidewalk_arrays := sidewalk_surface.mesh.surface_get_arrays(0)
		var sidewalk_uvs: PackedVector2Array = sidewalk_arrays[Mesh.ARRAY_TEX_UV]
		_expect(not sidewalk_uvs.is_empty(), "OSM sidewalks have no tiled texture UVs")
	var ground_surface := world.get_node_or_null("NaturalCoastTerrain") as MeshInstance3D
	if ground_surface != null and ground_surface.mesh != null \
			and ground_surface.mesh.get_surface_count() > 0:
		var ground_material := ground_surface.material_override as StandardMaterial3D
		_expect(ground_material != null and ground_material.albedo_texture != null
			and ground_material.albedo_texture.resource_path
				== "res://assets/textures/ground/ground037_alb_ht.png",
			"Natural terrain is missing the licensed Ground037 soil texture")
		_expect(ground_material != null and ground_material.normal_enabled
			and ground_material.normal_texture != null,
			"Natural terrain is missing its ground normal map")
		var ground_arrays := ground_surface.mesh.surface_get_arrays(0)
		var ground_uvs: PackedVector2Array = ground_arrays[Mesh.ARRAY_TEX_UV]
		_expect(not ground_uvs.is_empty(), "Natural terrain has no tiled ground UVs")
	var textured_infill := false
	for child in world.get_children():
		if not child is MultiMeshInstance3D \
				or not child.name.begins_with("GMC inferred house walls"):
			continue
		var house_mesh: Mesh = child.multimesh.mesh
		var house_material := house_mesh.surface_get_material(0) as StandardMaterial3D
		if house_material != null and house_material.albedo_texture != null \
				and house_material.normal_enabled:
			textured_infill = true
			break
	_expect(textured_infill, "Procedural residential infill has no textured PBR facade")
	var park_surface := world.get_node_or_null("GMC OSM green spaces") as MeshInstance3D
	if park_surface != null and park_surface.mesh != null \
		and park_surface.mesh.get_surface_count() > 0:
		var park_material := park_surface.material_override as StandardMaterial3D
		_expect(park_material != null and park_material.albedo_texture != null
			and park_material.albedo_texture.resource_path
				== "res://assets/textures/ground/ground037_alb_ht.png",
			"OSM parks are missing the shared ground texture")
		var park_arrays := park_surface.mesh.surface_get_arrays(0)
		var park_uvs: PackedVector2Array = park_arrays[Mesh.ARRAY_TEX_UV]
		_expect(not park_uvs.is_empty(), "OSM parks have no tiled ground UVs")
	var village := world.get_node_or_null("Medieval Village") as MedievalVillage
	_expect(village != null, "The Medieval Village POI was not generated")
	_expect(world.gmc_village_building_count == 4,
		"The Medieval Village should contain four modular buildings")
	if village != null:
		_expect(not world.on_water(village.village_center.x, village.village_center.y),
			"The Medieval Village was placed over water")
		_expect(not world.collides_at(village.village_center.x, village.village_center.y, 0.8),
			"The village courtyard is blocked by building collision")
		if not village.building_records.is_empty():
			var house: Dictionary = village.building_records[0]
			_expect(world.collides_at(float(house.x), float(house.z), 0.2),
				"Modular village house collision was not registered")
		var checked_fence := false
		var checked_wagon := false
		var checked_crates := false
		for object in village.collision_records:
			var kind := str(object.get("kind", ""))
			if kind == "village_fence" and not checked_fence:
				checked_fence = true
				_expect(world.collides_at(
					float(object.x), float(object.z), 0.0, float(object.base_y)),
					"Medieval village fence collision was not registered")
			elif kind == "village_wagon" and not checked_wagon:
				checked_wagon = true
				_expect(world.collides_at(
					float(object.x), float(object.z), 0.0, float(object.base_y)),
					"Medieval village wagon collision was not registered")
			elif kind == "village_crates" and not checked_crates:
				checked_crates = true
				_expect(world.collides_at(
					float(object.x), float(object.z), 0.0, float(object.base_y)),
					"Medieval village crate collision was not registered")
		_expect(checked_fence, "Medieval village has no fence collision records")
		_expect(checked_wagon, "Medieval village has no wagon collision records")
		_expect(checked_crates, "Medieval village has no crate collision records")
	_expect(world.gmc_bridge_count > 0,
		"Roads crossing mapped waterways are not raised as bridges")
	var bridge_is_walkable := false
	for segment in world.map_roads:
		if not segment.get("bridge", false):
			continue
		var midpoint: Vector2 = (segment.from + segment.to) * 0.5
		if world.surface_height(midpoint.x, midpoint.y) \
			> world.terrain_height(midpoint.x, midpoint.y) + 1.4:
			bridge_is_walkable = true
			break
	_expect(bridge_is_walkable, "Bridge deck height is not reflected in walkable terrain")
	var widest_road := 0.0
	for segment in world.map_roads:
		widest_road = maxf(widest_road, float(segment.width))
	_expect(widest_road >= 2.0, "OSM road widths were scaled more than once")
	_expect(world.map_green_areas.size() >= 5, "Mapped parks and wooded areas were not loaded")
	_expect(world.map_tree_positions.size() >= 10, "EZTree did not populate mapped green spaces")
	_expect(world.gmc_infill_count >= 100,
		"Residential infill did not add enough buildings to the sparse OSM footprints")
	_expect(world.gmc_midrise_count > 0,
		"Major streets lack the mid-rise commercial infill seen in Street View")
	var min_height := INF
	var max_height := -INF
	for x in range(-100, 101, 20):
		for z in range(-100, 101, 20):
			var height := world.terrain_height(float(x), float(z))
			min_height = minf(min_height, height)
			max_height = maxf(max_height, height)
	_expect(max_height - min_height > 2.0,
		"The SRTM terrain grid is missing or still flat across the mapped city")
	var forest_batches := 0
	for child in world.get_children():
		if child is MultiMeshInstance3D and child.name.begins_with("GMC park trees"):
			forest_batches += 1
	_expect(forest_batches > 0, "EZTree forest MultiMeshes were not created")
	if not world.map_tree_positions.is_empty():
		var tree: Vector2 = world.map_tree_positions[0]
		_expect(world.collides_at(
			tree.x, tree.y, 0.0, world.terrain_height(tree.x, tree.y)),
			"An EZTree trunk has no gameplay collision")
	_expect(world.collides_at(24.6, -14.3, 0.4),
		"An OSM building footprint is missing its gameplay collision")

	var spawn := world.random_road_spawn()
	_expect(spawn.has("x") and spawn.has("z") and spawn.has("yaw"),
		"Traffic spawn did not return a road position and heading")
	var safe_spawn := world.find_safe_spawn()
	_expect(not world.collides_at(safe_spawn.x, safe_spawn.y, 0.8),
		"The new-game spawn point intersects map geometry")

	var hud := HUD.new()
	add_child(hud)
	hud.enter_game()
	hud.set_map_roads(world.map_roads, world.map_water_segments)
	await get_tree().process_frame

	if failures.is_empty():
		print("GMC_MAP_AUDIT_OK roads=%d buildings=%d infill=%d midrise=%d bridges=%d village_buildings=%d water_segments=%d green_areas=%d trees=%d batches=%d" % [
			world.map_roads.size(), world.buildings.size(), world.gmc_infill_count,
			world.gmc_midrise_count, world.gmc_bridge_count,
			world.gmc_village_building_count,
			world.map_water_segments.size(), world.map_green_areas.size(),
			world.map_tree_positions.size(), forest_batches,
		])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)
