extends CSGBox3D

@export var other_object: CSGBox3D
@export var distance_to_label: Label
@export var distance_to_squared_label: Label
@export var distance_to_with_ref_label: Label
@export var size_and_position_label: Label
@export var raycast_distance_label: Label
@export var raycast_distance_with_offset_label: Label
@export var intersectray_distance_label: Label
@export var measure_from_ref_point: Node3D
@export var can_move := false

@onready var ray_cast_3d: RayCast3D = get_node("RayCast3D")
@onready var size_offset_x := size.x * 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_label_with_basic_info()

	if other_object == null:
		return

	_measure_distance_using_distance_to()
	_measure_distance_using_distance_squared_to()
	_measure_distance_using_raycast3d()
	_measure_distance_using_intersect_ray()
	_measure_distance_using_a_ref_point()

func _input(event: InputEvent) -> void:
	if not can_move:
		return

	if event.is_action_pressed("right"):
		global_position.x += 0.5

	if event.is_action_pressed("left"):
		global_position.x -= 0.5

	if event.is_action_pressed("up"):
		global_position.z -= 0.5

	if event.is_action_pressed("down"):
		global_position.z += 0.5

func _update_label_with_basic_info() -> void:
	size_and_position_label.text = "Size:\n{size}\nPosition:\n{pos}".format({
		"size": size,
		"pos": global_position
	})

func _measure_distance_using_distance_to() -> void:
	var distance = global_position.distance_to(other_object.global_position)

	if distance_to_label == null:
		return

	distance_to_label.text = "distance_to: {d}".format({
		"d": distance
	})

func _measure_distance_using_distance_squared_to() -> void:
	var distance2qr = global_position.distance_squared_to(other_object.global_position)

	if distance_to_squared_label == null:
		return

	distance_to_squared_label.text = "distance_squared_to: {dq}".format({
		"dq": distance2qr
	})

func _measure_distance_using_raycast3d() -> void:
	if ray_cast_3d == null:
		return

	# Update RayCast3D target position
	ray_cast_3d.target_position = other_object.global_position - global_position
	ray_cast_3d.force_raycast_update()

	if not ray_cast_3d.is_colliding():
		raycast_distance_label.text = "Raycast distance: [no hit]"
		raycast_distance_with_offset_label.text = "Raycast distance - offset: [no hit]"
		return

	var collision_point = ray_cast_3d.get_collision_point()
	var collision_distance = global_position.distance_to(collision_point)

	raycast_distance_label.text = "Raycast distance: {rd}".format({
		# we need to add this offset because the ray_cast_3d lives in local 0,0,0.
		"rd": collision_distance
	})

	raycast_distance_with_offset_label.text = "Raycast distance - offset: {rd}".format({
		# we need to add this offset because the ray_cast_3d lives in local 0,0,0.
		"rd": collision_distance - size_offset_x
	})

func _measure_distance_using_intersect_ray() -> void:
	var space = get_viewport().world_3d.direct_space_state
	var ray = PhysicsRayQueryParameters3D.new()
	ray.from = global_transform.origin
	ray.to = other_object.global_transform.origin
	ray.exclude = [self]
	var hit = space.intersect_ray(ray)

	if not hit:
		intersectray_distance_label.text = "Intersect_ray distance: [no hit]"
		return
	
	var hit_position = hit["position"]
	var collision_distance = global_position.distance_to(hit_position)
	intersectray_distance_label.text = "Intersect_ray distance: {rd}".format({
		"rd": collision_distance
	})

func _measure_distance_using_a_ref_point() -> void:
	if measure_from_ref_point == null:
		return

	# Exactly same as measuring using regular distance_to
	# We're just changing the "from" part.
	var distance = measure_from_ref_point.global_position.distance_to(other_object.global_position)

	distance_to_with_ref_label.text = "distance_to from ref: {d}".format({
		"d": distance
	})
