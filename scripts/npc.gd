class_name Npc
extends Node3D
## A standing character (rigged Rodin model, idle loop) with a name label and an optional quest
## marker. Models that have not been delivered fall back to a flagged stand-in model.

var npc_id: String = ""
var display_key: String = ""
var slot: String = ""
var height: float = 1.8
var standin: bool = false
var tint: Color = Color(1, 1, 1, 0)
var model: Node3D
var anim: AnimationPlayer
var label: Label3D
var marker: MeshInstance3D
var face_target: Node3D
var talk_radius: float = 3.4
var raw_model: String = ""   # unrigged glb under assets/models (Narayana), used instead of a char_ slot
var raw_scale: float = 1.0
var t: float = 0.0


func setup(cfg: Dictionary) -> void:
	npc_id = str(cfg.get("id", ""))
	display_key = str(cfg.get("name", "npc_" + npc_id))
	slot = str(cfg.get("slot", npc_id))
	height = float(cfg.get("h", 1.8))
	standin = bool(cfg.get("standin", false))
	if cfg.has("tint"):
		var c: Array = cfg["tint"]
		tint = Color(c[0], c[1], c[2], c[3] if c.size() > 3 else 0.3)
	var p: Array = cfg.get("pos", [0, 0])
	position = Vector3(float(p[0]), 0.0, float(p[1]))
	talk_radius = float(cfg.get("radius", 3.4))
	raw_model = str(cfg.get("model", ""))
	raw_scale = float(cfg.get("scale", 1.0))
	if cfg.has("face"):
		var f: Array = cfg["face"]
		rotation.y = atan2(-(float(f[0]) - position.x), -(float(f[1]) - position.z))


func _ready() -> void:
	add_to_group("npcs")
	var holder: Node3D = null
	if raw_model != "":
		holder = _raw()
	else:
		holder = Props.character(slot, height)
	if holder == null and cfg_fallback() != "":
		holder = Props.character(cfg_fallback(), height)
	if holder:
		model = holder
		model.rotation.y = PI      # Rodin models front +Z; the game fronts -Z
		add_child(model)
		var aps := model.find_children("*", "AnimationPlayer", true, false)
		if aps.size() > 0:
			anim = aps[0]
			if anim.has_animation("idle"):
				anim.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
				anim.play("idle")
		if tint.a > 0.0:
			var ov := StandardMaterial3D.new()
			ov.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ov.albedo_color = tint
			for mi in model.find_children("*", "MeshInstance3D", true, false):
				(mi as MeshInstance3D).material_overlay = ov
	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.015
	label.font_size = 30
	label.outline_size = 8
	label.position.y = height + 0.55
	label.modulate = Color(1.0, 0.92, 0.7)
	if Game.ui_font():
		label.font = Game.ui_font()
	label.text = Game.t(display_key)
	add_child(label)
	marker = MeshInstance3D.new()
	var m := PrismMesh.new()
	m.size = Vector3(0.28, 0.4, 0.28)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.25)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.75, 0.1)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.material = mat
	marker.mesh = m
	marker.rotation.x = PI
	marker.position.y = height + 1.05
	marker.visible = false
	add_child(marker)


func _raw() -> Node3D:
	var path := "res://assets/models/%s.glb" % raw_model
	if not ResourceLoader.exists(path):
		return null
	var h := Node3D.new()
	var m: Node3D = (load(path) as PackedScene).instantiate()
	m.scale = Vector3.ONE * raw_scale
	h.add_child(m)
	var l := OmniLight3D.new()
	l.light_color = Color(1.0, 0.85, 0.4)
	l.light_energy = 2.2
	l.omni_range = 12.0
	l.position = Vector3(0, 2.5, 1.5)
	h.add_child(l)
	return h


func cfg_fallback() -> String:
	return ""


func set_marker(on: bool) -> void:
	if marker:
		marker.visible = on


func _process(delta: float) -> void:
	t += delta
	if marker and marker.visible:
		marker.position.y = height + 1.05 + sin(t * 3.0) * 0.08
		marker.rotation.y += delta * 1.6
	if face_target and is_instance_valid(face_target):
		var d := face_target.global_position - global_position
		d.y = 0.0
		if d.length() < talk_radius * 2.2 and d.length() > 0.1:
			rotation.y = lerp_angle(rotation.y, atan2(-d.x, -d.z), 1.0 - exp(-4.0 * delta))


func distance_to(p: Vector3) -> float:
	return Vector2(global_position.x - p.x, global_position.z - p.z).length()
