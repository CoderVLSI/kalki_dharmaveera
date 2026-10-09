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
var _earth: Node3D
var _earth_mats: Array = []
var _dim: StandardMaterial3D
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
	_cam.position = Vector3(0, 2.2, 8.0)
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

	# the Earth, ash-grey and dim until the vow warms it
	_earth = Props.spawn("prop_earth")
	_earth.scale = Vector3.ONE * 0.6
	_earth.position = Vector3(0, 0.9, 3.6)
	_vp.add_child(_earth)
	for mi in _earth.find_children("*", "MeshInstance3D", true, false):
		if not mi.name.begins_with("earth"):
			mi.visible = false   # the shipping-routes shell renders as an opaque grey ball
			continue
		_earth_mats.append(mi)
		var dim := StandardMaterial3D.new()
		dim.albedo_color = Color(0.35, 0.33, 0.36)
		(mi as MeshInstance3D).material_overlay = dim if mi.name.begins_with("earth") else null
		_dim = dim
	_dim.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_dim.albedo_color = Color(0.25, 0.22, 0.22, 0.45)

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
	var fill := OmniLight3D.new()   # keeps the Earth readable in the dark
	fill.light_energy = 1.6
	fill.omni_range = 9.0
	fill.position = Vector3(0, 2.5, 7.0)
	_vp.add_child(fill)

	# the devatas are living, radiant beings, not idols: a column of rising light each
	# (Brahma, Indra, Lakshmi...). No CC-licensed living models of them exist yet.
	var hues := [Color(1.0, 0.75, 0.35), Color(0.7, 0.85, 1.0), Color(1.0, 0.6, 0.7), Color(0.75, 1.0, 0.85), Color(0.95, 0.95, 1.0)]
	var xs := [-5.2, -3.8, -2.3, 2.3, 3.8]
	var slots := {2: ["brahma", 2.4], 3: ["shiva", 2.6]}   # xs index -> hand-made model, if present
	for i in xs.size():
		var pos := Vector3(xs[i], 0.0, 1.0 - absf(xs[i]) * 0.1)
		var made: Node3D = null
		if slots.has(i):
			made = Props.character(slots[i][0], slots[i][1])
		if made:
			made.position = pos
			_vp.add_child(made)
			made.look_at(Vector3(0, 0, 0.4))   # +Z front; side-on to the camera, turned toward the Lord and the Earth
			made.rotate_y(PI)
			_devas.append(made)
			for ap in made.find_children("*", "AnimationPlayer", true, false):   # rigged: breathe
				if (ap as AnimationPlayer).has_animation("idle"):
					(ap as AnimationPlayer).get_animation("idle").loop_mode = Animation.LOOP_LINEAR
					(ap as AnimationPlayer).play("idle")
		else:
			_vp.add_child(_presence(hues[i], pos))

	for lx in [-1.6, 1.6]:
		var lotus := Props.spawn("prop_lotus")
		if lotus:
			lotus.position = Vector3(lx, 0, -4.2)
			lotus.scale = Vector3.ONE * 2.0
			_vp.add_child(lotus)
			_devas.append(lotus)

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

	# the newborn in Shambhala: a real cradle, a real infant, lotuses, golden light
	_cradle = Node3D.new()
	_cradle.position = Vector3(0, 0, 4.5)
	_cradle.visible = false
	var cr := Props.spawn("prop_cradle")
	if cr:
		cr.scale = Vector3.ONE * 1.2
		_cradle.add_child(cr)
	var baby := Props.character("kalki_baby", 0.8)   # hand-made newborn, if provided
	if baby:
		baby.position = Vector3(0, 0.45, 0)
	else:
		baby = Props.spawn("prop_infant_b")
		if baby:
			baby.scale = Vector3.ONE * 2.4
			baby.position = Vector3(0, 0.55, 0)
	if baby:
		_cradle.add_child(baby)
	for lx in [-0.9, 0.9]:
		var l := Props.spawn("prop_lotus")
		if l:
			l.position = Vector3(lx, 0, 0.5)
			_cradle.add_child(l)
	var cl := OmniLight3D.new()
	cl.light_color = Color(1.0, 0.85, 0.5)
	cl.light_energy = 2.2
	cl.omni_range = 9.0
	cl.position = Vector3(0, 2.0, 0.5)
	_cradle.add_child(cl)
	_vp.add_child(_cradle)


func _presence(c: Color, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	var sparks := CPUParticles3D.new()
	sparks.amount = 90
	sparks.lifetime = 3.0
	sparks.preprocess = 3.0
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = 0.35
	sparks.direction = Vector3.UP
	sparks.spread = 6.0
	sparks.initial_velocity_min = 0.5
	sparks.initial_velocity_max = 1.1
	sparks.gravity = Vector3.ZERO
	var m := SphereMesh.new()
	m.radius = 0.035
	m.height = 0.07
	m.material = _glow(c)
	sparks.mesh = m
	n.add_child(sparks)
	var l := OmniLight3D.new()
	l.light_color = c
	l.light_energy = 1.4
	l.omni_range = 5.0
	l.position.y = 1.4
	n.add_child(l)
	_devas.append(n)
	return n


func _glow(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.emission_enabled = true
	m.emission = c
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _say(id: String) -> float:
	var line: Dictionary = Game.dialogue.get(id, {})
	_sub.text = "%s:  %s" % [line.get("speaker", ""), line.get("text", "")]
	_tier.text = "[%s]" % Game.tier_label(line)
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
	glow.tween_property(_dim, "albedo_color", Color(1.0, 0.8, 0.3, 0.0), 3.0)
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
		_cam.position.z = maxf(6.4, 8.0 - _t * 0.12)   # slow dolly toward the Lord
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
