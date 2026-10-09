class_name Prologue
extends CanvasLayer
## Opening cutscene: Brahma and the devatas petition Narayana, he vows to descend as Kalki in
## Shambhala, and we cut to the newborn (a placeholder cradle until a Bala Kalki model exists).
## Own 3D world in a SubViewport so it never touches the game scene. Skippable. Voice from the
## prologue_* lines in data/dialogue.json (tier-tagged, canon basis in "ref").

signal finished

const LINES := ["prologue_plea", "prologue_vow", "prologue_birth"]

var _vp: SubViewport
var _cam: Camera3D
var _fade: ColorRect
var _sub: Label
var _tier: Label
var _panel: PanelContainer
var _narayana: Node3D
var _nlight: OmniLight3D
var _earth: MeshInstance3D
var _devas: Array[Node3D] = []
var _cradle: Node3D
var _done: bool = false
var _t: float = 0.0
var _push: bool = true


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	var box := SubViewportContainer.new()
	box.stretch = true
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(box)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.size = get_viewport().get_visible_rect().size
	box.add_child(_vp)
	_build_world()

	var ui := Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	var w := minf(880.0, get_viewport().get_visible_rect().size.x - 40.0)
	_panel.custom_minimum_size = Vector2(w, 0)
	_panel.position = Vector2(-w / 2.0, -170)
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_panel)
	var v := VBoxContainer.new()
	_panel.add_child(v)
	_sub = Label.new()
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.add_theme_font_size_override("font_size", 22)
	v.add_child(_sub)
	_tier = Label.new()
	_tier.add_theme_font_size_override("font_size", 12)
	_tier.modulate = Color(0.8, 0.8, 0.6, 0.8)
	v.add_child(_tier)
	var skip := Label.new()
	skip.text = "tap / Enter to skip"
	skip.add_theme_font_size_override("font_size", 14)
	skip.modulate = Color(1, 1, 1, 0.6)
	skip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skip.position = Vector2(-190, 14)
	ui.add_child(skip)
	_run()


func _build_world() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.02, 0.02, 0.06)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.25, 0.22, 0.35)
	env.environment.glow_enabled = true
	_vp.add_child(env)
	_cam = Camera3D.new()
	_cam.position = Vector3(0, 2.4, 9.5)
	_vp.add_child(_cam)
	_cam.look_at(Vector3(0, 2.4, -5))

	# stars
	var stars := CPUParticles3D.new()
	stars.amount = 140
	stars.lifetime = 100.0
	stars.preprocess = 1.0
	stars.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	stars.emission_box_extents = Vector3(30, 14, 4)
	stars.position = Vector3(0, 6, -26)
	stars.gravity = Vector3.ZERO
	var sm := SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.1
	sm.material = _glow(Color(1, 0.95, 0.8))
	stars.mesh = sm
	_vp.add_child(stars)

	# dim, ash-grey earth that the vow warms
	_earth = MeshInstance3D.new()
	var em := SphereMesh.new()
	em.radius = 1.3
	em.height = 2.6
	var emat := StandardMaterial3D.new()
	emat.albedo_color = Color(0.3, 0.3, 0.34)
	emat.emission_enabled = true
	emat.emission = Color(0.3, 0.05, 0.05)
	emat.emission_energy_multiplier = 0.4
	em.material = emat
	_earth.mesh = em
	_earth.position = Vector3(0, -0.5, 3.2)
	_vp.add_child(_earth)

	# Narayana, far and still
	var scn: PackedScene = load("res://assets/models/narayana.glb")
	_narayana = scn.instantiate()
	_narayana.scale = Vector3.ONE * 3.6
	_narayana.position = Vector3(0, 0.8, -5)
	_vp.add_child(_narayana)
	_nlight = OmniLight3D.new()
	_nlight.light_color = Color(1.0, 0.85, 0.4)
	_nlight.light_energy = 0.4
	_nlight.omni_range = 18.0
	_nlight.position = Vector3(0, 3.2, -2.5)
	_vp.add_child(_nlight)

	# Brahma and the devatas, kneeling in an arc (simple glowing figures: invented placeholders)
	var cols := [Color(1.0, 0.55, 0.45), Color(0.9, 0.9, 0.95), Color(1.0, 0.7, 0.3), Color(0.7, 0.85, 1.0), Color(0.6, 1.0, 0.8)]
	var xs := [-4.6, -3.0, 3.0, 4.6, 6.0]   # leave the centre line clear for the Lord; Brahma (white) at -3.0
	for i in cols.size():
		var f := _figure(cols[i], 1.15 if i == 1 else 1.0)
		f.position = Vector3(xs[i], 0, 1.0 - absf(xs[i]) * 0.12)
		f.look_at(Vector3(0, 0, -5))
		_devas.append(f)
		_vp.add_child(f)

	var floor_mesh := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 9.0
	disc.bottom_radius = 9.0
	disc.height = 0.1
	var dm := StandardMaterial3D.new()
	dm.albedo_color = Color(0.08, 0.07, 0.12)
	dm.roughness = 0.4
	disc.material = dm
	floor_mesh.mesh = disc
	floor_mesh.position = Vector3(0, -0.06, -1)
	_vp.add_child(floor_mesh)

	# the newborn: placeholder cradle + swaddled infant in golden light (hidden until the last beat)
	_cradle = Node3D.new()
	_cradle.position = Vector3(0, 0, 4.5)
	_cradle.visible = false
	var bed := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.3, 0.3, 0.8)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.3, 0.18)
	bm.material = wood
	bed.mesh = bm
	bed.position.y = 0.35
	_cradle.add_child(bed)
	var cloth := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.2
	cm.height = 0.8
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.9, 0.6)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.8, 0.3)
	cmat.emission_energy_multiplier = 0.6
	cm.material = cmat
	cloth.mesh = cm
	cloth.rotation_degrees.z = 90
	cloth.position.y = 0.62
	_cradle.add_child(cloth)
	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.2
	hm.height = 0.4
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.45, 0.6, 0.85)   # Vishnu's dark-blue hue, soft
	hm.material = skin
	head.mesh = hm
	head.position = Vector3(-0.5, 0.7, 0)
	_cradle.add_child(head)
	var halo := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.55
	tm.outer_radius = 0.6
	tm.material = _glow(Color(1.0, 0.85, 0.4))
	halo.mesh = tm
	halo.position = Vector3(-0.5, 0.7, 0)
	halo.rotation_degrees.x = 90
	_cradle.add_child(halo)
	var cl := OmniLight3D.new()
	cl.light_color = Color(1.0, 0.85, 0.5)
	cl.light_energy = 2.2
	cl.omni_range = 9.0
	cl.position = Vector3(0, 2.0, 0.5)
	_cradle.add_child(cl)
	_vp.add_child(_cradle)


func _glow(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.emission_enabled = true
	m.emission = c
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _figure(c: Color, s: float) -> Node3D:
	var n := Node3D.new()
	n.scale = Vector3.ONE * s
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.38
	cap.height = 1.3
	var mat := StandardMaterial3D.new()
	mat.albedo_color = c * 0.55
	mat.emission_enabled = true
	mat.emission = c
	mat.emission_energy_multiplier = 0.5
	cap.material = mat
	body.mesh = cap
	body.position.y = 0.65
	n.add_child(body)
	var head := MeshInstance3D.new()
	var sp := SphereMesh.new()
	sp.radius = 0.24
	sp.height = 0.48
	sp.material = mat
	head.mesh = sp
	head.position.y = 1.5
	n.add_child(head)
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.34
	tm.outer_radius = 0.38
	tm.material = _glow(c)
	ring.mesh = tm
	ring.position.y = 1.5
	ring.rotation_degrees.x = 90
	n.add_child(ring)
	return n


func _say(id: String) -> float:
	var line: Dictionary = Game.dialogue.get(id, {})
	_sub.text = "%s:  %s" % [line.get("speaker", ""), line.get("text", "")]
	_tier.text = "[%s]" % line.get("tier", "")
	_panel.visible = true
	Game.voice_line.emit(id)
	var path := Sfx.VOICE_DIR % id
	var len := 4.0
	if ResourceLoader.exists(path):
		len = (load(path) as AudioStream).get_length()
	return len + 0.8


func _run() -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 1.5)
	await get_tree().create_timer(1.2).timeout
	if _done:
		return
	# 1. the plea
	var d := _say(LINES[0])
	var pulse := create_tween().set_loops()
	for f in _devas:
		pulse.parallel().tween_property(f, "position:y", 0.12, 1.4).as_relative()
	pulse.chain().tween_interval(0.01)
	await get_tree().create_timer(d).timeout
	if _done:
		return
	# 2. the vow: Narayana's light swells and warms the earth
	d = _say(LINES[1])
	var glow := create_tween().set_parallel(true)
	glow.tween_property(_nlight, "light_energy", 4.5, 2.5)
	glow.tween_property(_earth.mesh.material, "emission", Color(1.0, 0.7, 0.25), 3.0)
	glow.tween_property(_earth.mesh.material, "albedo_color", Color(0.75, 0.65, 0.4), 3.0)
	await get_tree().create_timer(d).timeout
	if _done:
		return
	# 3. the birth in Shambhala
	var out := create_tween()
	out.tween_property(_fade, "color", Color(1, 0.93, 0.7, 1.0), 1.0)
	await out.finished
	if _done:
		return
	for n in [_narayana, _earth] + _devas:
		n.visible = false
	_nlight.visible = false
	_cradle.visible = true
	_push = false
	_cam.position = Vector3(1.2, 1.5, 7.5)
	_cam.look_at(Vector3(0, 0.9, 4.5))
	var inn := create_tween()
	inn.tween_property(_fade, "color:a", 0.0, 1.2)
	d = _say(LINES[2])
	await get_tree().create_timer(d).timeout
	_finish()


func _process(delta: float) -> void:
	_t += delta
	if _push:
		_cam.position.z = maxf(7.0, 9.5 - _t * 0.12)   # slow dolly toward the Lord
	elif _cradle.visible:
		_cam.position.z = maxf(6.2, 7.5 - (_t - 20.0) * 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if _t < 0.6:
		return
	var skip := false
	if event is InputEventKey and event.pressed and not event.echo:
		skip = event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_ESCAPE]
	elif event is InputEventMouseButton and event.pressed:
		skip = true
	elif event is InputEventScreenTouch and event.pressed:
		skip = true
	if skip:
		_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	var out := create_tween()
	out.tween_property(_fade, "color", Color(0, 0, 0, 1), 0.5)
	await out.finished
	finished.emit()
	queue_free()
