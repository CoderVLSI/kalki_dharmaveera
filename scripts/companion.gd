class_name Companion
extends Node3D
## Shuka the parrot, Kalki's companion (Kalki Purana I.3, gift of Mahadeva): the user's Rodin model
## (assets/models/char_shuka.glb), hovering beside and behind Kalki.

var target: Node3D
var model: Node3D
var t: float = 0.0
var height: float = 0.9
var scripted: bool = false
var turn_deg: float = 180.0   # Rodin models front +Z; the game fronts -Z


func _ready() -> void:
	var m := Props.character("shuka", height)
	if m == null:
		return
	model = m
	model.rotation.y = deg_to_rad(turn_deg)
	add_child(model)


## Scouting flight (M05): Shuka flies the waypoints [[x, z], ...] and comes back; the camera follows him.
func fly_path(points: Array) -> void:
	scripted = true
	for pt in points:
		var dest := Vector3(float(pt[0]), 7.0, float(pt[1]))
		var look := (dest - global_position)
		look.y = 0.0
		if look.length() > 0.1:
			rotation.y = atan2(-look.x, -look.z)
		var tw := create_tween()
		tw.tween_property(self, "global_position", dest, maxf(0.6, global_position.distance_to(dest) / 11.0)).set_trans(Tween.TRANS_SINE)
		await tw.finished
		await get_tree().create_timer(0.6).timeout
	var home := target.global_position + Vector3(-1.4, 2.4, 0.6)
	var back := create_tween()
	back.tween_property(self, "global_position", home, maxf(0.8, global_position.distance_to(home) / 11.0)).set_trans(Tween.TRANS_SINE)
	await back.finished
	scripted = false


func _process(delta: float) -> void:
	if target == null or model == null or scripted:
		return
	t += delta
	var yaw: float = target.get("yaw") if target.get("yaw") != null else target.rotation.y
	var back := Basis(Vector3.UP, yaw)
	var want: Vector3 = target.global_position + back * Vector3(-1.4, 2.4 + sin(t * 2.2) * 0.12, 0.6)
	global_position = global_position.lerp(want, 1.0 - exp(-4.0 * delta))
	rotation.y = lerp_angle(rotation.y, yaw, 1.0 - exp(-5.0 * delta))
	rotation.z = sin(t * 2.2) * 0.08
