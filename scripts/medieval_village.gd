class_name MedievalVillage
extends Node3D

const FLOOR_BRICK: PackedScene = preload("res://assets/medieval_village/Floor_Brick.gltf")
const DOOR: PackedScene = preload("res://assets/medieval_village/Door_1_Flat.gltf")
const DOOR_WALL: PackedScene = preload("res://assets/medieval_village/Wall_Plaster_Door_Flat.gltf")
const PLASTER_WALL: PackedScene = preload("res://assets/medieval_village/Wall_Plaster_Straight.gltf")
const PLASTER_WINDOW: PackedScene = preload("res://assets/medieval_village/Wall_Plaster_Window_Wide_Flat.gltf")
const BRICK_WALL: PackedScene = preload("res://assets/medieval_village/Wall_UnevenBrick_Straight.gltf")
const BRICK_WINDOW: PackedScene = preload("res://assets/medieval_village/Wall_UnevenBrick_Window_Wide_Flat.gltf")
const ROOF_4X4: PackedScene = preload("res://assets/medieval_village/Roof_RoundTiles_4x4.gltf")
const ROOF_4X6: PackedScene = preload("res://assets/medieval_village/Roof_RoundTiles_4x6.gltf")
const DORMER: PackedScene = preload("res://assets/medieval_village/Roof_Dormer_RoundTile.gltf")
const WAGON: PackedScene = preload("res://assets/medieval_village/Prop_Wagon.gltf")
const CRATE: PackedScene = preload("res://assets/medieval_village/Prop_Crate.gltf")
const FENCE: PackedScene = preload("res://assets/medieval_village/Prop_WoodenFence_Single.gltf")
const VINE: PackedScene = preload("res://assets/medieval_village/Prop_Vine1.gltf")

var building_records: Array[Dictionary] = []
var collision_records: Array[Dictionary] = []
var village_center := Vector2.ZERO
var _world: Node3D


func build(world: Node3D, center: Vector2) -> void:
	_world = world
	village_center = center
	position = Vector3(center.x, 0.0, center.y)
	_build_house(Vector2(-12.0, -12.0), 2, 2, PLASTER_WALL, PLASTER_WINDOW, ROOF_4X4)
	_build_house(Vector2(12.0, -12.0), 3, 2, BRICK_WALL, BRICK_WINDOW, ROOF_4X6)
	_build_house(Vector2(-12.0, 12.0), 2, 3, PLASTER_WALL, PLASTER_WINDOW, ROOF_4X6)
	_build_house(Vector2(12.0, 12.0), 2, 2, BRICK_WALL, BRICK_WINDOW, ROOF_4X4)
	_build_courtyard()
	_build_props()
	_build_access_trail()
	_add_name_sign()


func _build_house(
	local_center: Vector2,
	width_sections: int,
	depth_sections: int,
	wall_scene: PackedScene,
	window_scene: PackedScene,
	roof_scene: PackedScene
) -> void:
	var width := float(width_sections) * 2.0
	var depth := float(depth_sections) * 2.0
	var world_x := village_center.x + local_center.x
	var world_z := village_center.y + local_center.y
	var base_y := float(_world.call("terrain_height", world_x, world_z))
	var house := Node3D.new()
	house.name = "Village house %02d" % (building_records.size() + 1)
	house.position = Vector3(local_center.x, base_y, local_center.y)
	var toward_center := -local_center.normalized()
	house.rotation.y = atan2(-toward_center.x, -toward_center.y)
	add_child(house)

	for x_index in width_sections:
		for z_index in depth_sections:
			_add_module(
				house, FLOOR_BRICK,
				Vector3(-width * 0.5 + 1.0 + x_index * 2.0, 0.02,
					-depth * 0.5 + 1.0 + z_index * 2.0))

	var door_index := floori(float(width_sections) / 2.0)
	for index in width_sections:
		var x := -width * 0.5 + 1.0 + index * 2.0
		var front_wall := DOOR_WALL if index == door_index else window_scene
		_add_module(house, front_wall, Vector3(x, 0.0, -depth * 0.5))
		if index == door_index:
			_add_module(house, DOOR, Vector3(x, 0.0, -depth * 0.5 - 0.22))
		var rear_wall := window_scene if index % 2 == 0 else wall_scene
		_add_module(house, rear_wall, Vector3(x, 0.0, depth * 0.5), PI)

	for index in depth_sections:
		var z := -depth * 0.5 + 1.0 + index * 2.0
		_add_module(house, wall_scene, Vector3(-width * 0.5, 0.0, z), -PI * 0.5)
		_add_module(house, wall_scene, Vector3(width * 0.5, 0.0, z), PI * 0.5)

	var roof_yaw := PI * 0.5 if width_sections > depth_sections else 0.0
	_add_module(house, roof_scene, Vector3(0.0, 3.05, 0.0), roof_yaw)
	if width_sections + depth_sections >= 5:
		_add_module(house, DORMER, Vector3(0.0, 4.65, 0.0), roof_yaw)

	var collision_width := width + 0.65
	var collision_depth := depth + 0.65
	var house_collision := {
		"x": world_x,
		"z": world_z,
		"w": collision_width,
		"d": collision_depth,
		"h": 7.5,
		"yaw": house.rotation.y,
		"base_y": base_y,
		"kind": "village_house",
	}
	building_records.append(house_collision)
	collision_records.append(house_collision)


func _build_courtyard() -> void:
	for x_index in range(-2, 2):
		for z_index in range(-2, 2):
			_add_module(
				self, FLOOR_BRICK,
				Vector3(x_index * 2.0 + 1.0, 0.02, z_index * 2.0 + 1.0))

	for index in range(-8, 9, 2):
		if absf(index) < 3.0:
			continue
		_add_fence(Vector2(index, 18.0), 0.0)
		_add_fence(Vector2(index, -18.0), PI)
		_add_fence(Vector2(18.0, index), PI * 0.5)
		_add_fence(Vector2(-18.0, index), -PI * 0.5)


func _add_fence(local_position: Vector2, yaw: float) -> void:
	var base_y := _height_at(local_position.x, local_position.y)
	_add_module(
		self, FENCE, Vector3(local_position.x, base_y, local_position.y), yaw)
	_register_collision(local_position, 2.0, 0.22, 1.8, yaw, base_y, "village_fence")


func _build_props() -> void:
	var wagon_position := Vector2(-5.0, 1.0)
	var wagon_base_y := _height_at(wagon_position.x, wagon_position.y)
	_add_module(self, WAGON, Vector3(wagon_position.x, wagon_base_y, wagon_position.y), -0.3)
	_register_collision(wagon_position, 3.0, 1.5, 1.8, -0.3, wagon_base_y, "village_wagon")
	var crate_position := Vector2(4.5, 2.5)
	var crate_base_y := _height_at(crate_position.x, crate_position.y)
	_add_module(self, CRATE, Vector3(crate_position.x, crate_base_y, crate_position.y))
	_add_module(self, CRATE, Vector3(5.1, _height_at(5.1, 2.5) + 0.55, 2.5), 0.2)
	_register_collision(
		Vector2(4.8, 2.5), 1.6, 1.2, 1.4, 0.0, crate_base_y, "village_crates")
	_add_module(self, VINE, Vector3(-13.0, _height_at(-13.0, -12.0) + 0.5, -12.0), PI * 0.5)
	_add_module(self, VINE, Vector3(13.0, _height_at(13.0, 12.0) + 0.5, 12.0), -PI * 0.5)


func _register_collision(
	local_center: Vector2,
	width: float,
	depth: float,
	height: float,
	yaw: float,
	base_y: float,
	kind: String
) -> void:
	collision_records.append({
		"x": village_center.x + local_center.x,
		"z": village_center.y + local_center.y,
		"w": width,
		"d": depth,
		"h": height,
		"yaw": yaw,
		"base_y": base_y,
		"kind": kind,
	})


func _build_access_trail() -> void:
	var nearest_road_point := Vector2.ZERO
	var nearest_distance := INF
	var roads: Array = _world.get("map_roads")
	for segment in roads:
		var a: Vector2 = segment.from
		var b: Vector2 = segment.to
		var direction := b - a
		if direction.length_squared() <= 0.0:
			continue
		var t := clampf((village_center - a).dot(direction) / direction.length_squared(), 0.0, 1.0)
		var candidate := a + direction * t
		var distance := candidate.distance_to(village_center)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_road_point = candidate
	if nearest_distance == INF:
		push_warning("Medieval village has no mapped road from which to create an access trail")
		return

	var direction := village_center - nearest_road_point
	var side := direction.normalized().orthogonal()
	var trail_points := PackedVector2Array([
		nearest_road_point,
		nearest_road_point.lerp(village_center, 0.34) + side * 12.0,
		nearest_road_point.lerp(village_center, 0.68) - side * 8.0,
		village_center,
	])
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(trail_points.size() - 1):
		var start := trail_points[index]
		var end := trail_points[index + 1]
		var steps := maxi(1, ceili(start.distance_to(end) / 7.0))
		for step in steps:
			var a := start.lerp(end, float(step) / float(steps))
			var b := start.lerp(end, float(step + 1) / float(steps))
			var lateral := (b - a).normalized().orthogonal() * 1.25
			for point in [a + lateral, a - lateral, b - lateral,
				a + lateral, b - lateral, b + lateral]:
				surface.set_normal(Vector3.UP)
				surface.add_vertex(Vector3(
					point.x - village_center.x,
					float(_world.call("terrain_height", point.x, point.y)) + 0.06,
					point.y - village_center.y))

	var trail := MeshInstance3D.new()
	trail.name = "Village access trail"
	trail.mesh = surface.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("746148")
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	trail.material_override = material
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(trail)


func _add_name_sign() -> void:
	var sign := Label3D.new()
	sign.name = "Village name sign"
	sign.text = "VILA MEDIEVAL"
	sign.font_size = 34
	sign.pixel_size = 0.012
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.modulate = Color("f5e6bf")
	sign.outline_size = 8
	sign.outline_modulate = Color("382a1e")
	sign.position = Vector3(0.0, _height_at(0.0, 0.0) + 9.0, 0.0)
	add_child(sign)


func _add_module(
	parent: Node3D,
	scene: PackedScene,
	local_position: Vector3,
	yaw := 0.0
) -> void:
	var instance := scene.instantiate() as Node3D
	if instance == null:
		push_error("A Medieval Village asset did not instantiate as Node3D")
		return
	instance.position = local_position
	instance.rotation.y = yaw
	parent.add_child(instance)


func _height_at(local_x: float, local_z: float) -> float:
	return float(_world.call(
		"terrain_height",
		village_center.x + local_x,
		village_center.y + local_z))
