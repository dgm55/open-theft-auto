class_name CapybaraPet
extends Node3D

const FOLLOW_SPEED := 4.0
const TELEPORT_DISTANCE := 24.0

var _unit_sphere := SphereMesh.new()
var _body_material := StandardMaterial3D.new()
var _light_material := StandardMaterial3D.new()
var _dark_material := StandardMaterial3D.new()
var _legs: Array[MeshInstance3D] = []
var _walk_clock := 0.0


func _ready() -> void:
	name = "CapybaraPet"
	_unit_sphere.radius = 1.0
	_unit_sphere.height = 2.0
	_body_material.albedo_color = Color(0.42, 0.27, 0.16)
	_light_material.albedo_color = Color(0.59, 0.41, 0.25)
	_dark_material.albedo_color = Color(0.12, 0.08, 0.05)

	_add_ellipsoid(Vector3(0.68, 0.48, 1.05), Vector3(0, 0.66, 0), _body_material)
	_add_ellipsoid(Vector3(0.41, 0.40, 0.46), Vector3(0, 0.92, 0.86), _light_material)
	_add_ellipsoid(Vector3(0.31, 0.20, 0.37), Vector3(0, 0.73, 1.19), _body_material)
	_add_ellipsoid(Vector3(0.13, 0.09, 0.08), Vector3(0, 0.76, 1.53), _dark_material)
	for side in [-1.0, 1.0]:
		_add_ellipsoid(Vector3(0.045, 0.045, 0.04),
			Vector3(side * 0.32, 1.04, 1.12), _dark_material)
		_add_ellipsoid(Vector3(0.12, 0.15, 0.10),
			Vector3(side * 0.27, 1.22, 0.76), _light_material)
	_add_legs()


func follow(world: CityWorld, target: Vector3, target_yaw: float, delta: float) -> void:
	var forward := Vector3(sin(target_yaw), 0.0, cos(target_yaw))
	var right := Vector3(forward.z, 0.0, -forward.x)
	var desired := target - forward * 2.0 + right * 1.1
	desired.y = world.surface_height(desired.x, desired.z)

	var offset := desired - global_position
	offset.y = 0.0
	if offset.length() > TELEPORT_DISTANCE:
		global_position = desired
		offset = Vector3.ZERO
	else:
		var step := minf(offset.length(), FOLLOW_SPEED * maxf(delta, 0.0))
		if step > 0.001:
			var movement := offset.normalized() * step
			var next_x := global_position.x + movement.x
			var next_z := global_position.z + movement.z
			if not world.collides_at(next_x, global_position.z, 0.35):
				global_position.x = next_x
			if not world.collides_at(global_position.x, next_z, 0.35):
				global_position.z = next_z

	if offset.length() > 0.05:
		var facing := atan2(offset.x, offset.z)
		rotation.y = lerp_angle(rotation.y, facing, minf(1.0, delta * 8.0))
	_walk_clock += delta * (9.0 if offset.length() > 0.15 else 2.0)
	for index in _legs.size():
		_legs[index].rotation.x = sin(_walk_clock + index * PI) * 0.18
	global_position.y = lerpf(global_position.y,
		world.surface_height(global_position.x, global_position.z), minf(1.0, delta * 12.0))


func _add_ellipsoid(size: Vector3, at: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _unit_sphere
	mesh_instance.scale = size
	mesh_instance.position = at
	mesh_instance.material_override = material
	add_child(mesh_instance)


func _add_legs() -> void:
	var leg_mesh := CylinderMesh.new()
	leg_mesh.top_radius = 0.10
	leg_mesh.bottom_radius = 0.13
	leg_mesh.height = 0.40
	for x in [-0.40, 0.40]:
		for z in [-0.58, 0.58]:
			var leg := MeshInstance3D.new()
			leg.mesh = leg_mesh
			leg.position = Vector3(x, 0.23, z)
			leg.material_override = _body_material
			add_child(leg)
			_legs.append(leg)
