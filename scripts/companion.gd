class_name Companion
extends Node3D
## Shuka the parrot, Kalki's companion (Kalki Purana I.3, gift of Mahadeva): the user's Rodin model
## (assets/models/char_shuka.glb), hovering beside and behind Kalki.

var target: Node3D
var model: Node3D
var t: float = 0.0
var height: float = 0.9
var turn_deg: float = 180.0   # Rodin models front +Z; the game fronts -Z


func _ready() -> void:
	var m := Props.character("shuka", height)
	if m == null:
		return
	model = m
	model.rotation.y = deg_to_rad(turn_deg)
	add_child(model)


func _process(delta: float) -> void:
	if target == null or model == null:
		return
	t += delta
	var yaw: float = target.get("yaw") if target.get("yaw") != null else target.rotation.y
	var back := Basis(Vector3.UP, yaw)
	var want: Vector3 = target.global_position + back * Vector3(-1.4, 2.4 + sin(t * 2.2) * 0.12, 0.6)
	global_position = global_position.lerp(want, 1.0 - exp(-4.0 * delta))
	rotation.y = lerp_angle(rotation.y, yaw, 1.0 - exp(-5.0 * delta))
	rotation.z = sin(t * 2.2) * 0.08
