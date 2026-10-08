class_name CameraRig
extends Node3D
## Third-person follow camera. Q/E (or right-mouse drag) orbit, wheel zooms.

var target: Node3D
var cam: Camera3D
var yaw: float = 0.0
var pitch: float = deg_to_rad(-24.0)
var distance: float = 9.5
var shake_amt: float = 0.0
var dragging: bool = false
var demo_orbit: bool = false


func _ready() -> void:
	cam = Camera3D.new()
	cam.fov = 62.0
	cam.far = 900.0
	cam.current = true
	add_child(cam)


func drag(rel: Vector2) -> void:
	yaw -= rel.x * 0.006
	pitch = clampf(pitch - rel.y * 0.004, deg_to_rad(-60.0), deg_to_rad(-5.0))


func add_shake(a: float) -> void:
	shake_amt = maxf(shake_amt, a)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			distance = clampf(distance - 0.8, 4.0, 18.0)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			distance = clampf(distance + 0.8, 4.0, 18.0)
	elif event is InputEventMouseMotion and dragging:
		var mm := event as InputEventMouseMotion
		yaw -= mm.relative.x * 0.006
		pitch = clampf(pitch - mm.relative.y * 0.004, deg_to_rad(-60.0), deg_to_rad(-5.0))


func _process(delta: float) -> void:
	if target == null:
		return
	yaw += (Input.get_axis("cam_right", "cam_left")) * 2.2 * delta
	if Game.demo or demo_orbit:
		yaw += 0.35 * delta
	var focus := target.global_position + Vector3(0, 1.6, 0)
	global_position = global_position.lerp(focus, 1.0 - exp(-10.0 * delta))
	rotation = Vector3(pitch, yaw, 0)
	cam.position = Vector3(0, 0, distance)
	shake_amt = maxf(0.0, shake_amt - delta * 1.8)
	cam.h_offset = randf_range(-1, 1) * shake_amt * 0.35
	cam.v_offset = randf_range(-1, 1) * shake_amt * 0.35
