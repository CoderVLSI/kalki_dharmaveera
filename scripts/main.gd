extends Node3D
## Mission host. Builds the world, player, camera, HUD, NPCs and runs a mission's objective list
## (data/missions.json -> play). Campaign.current == "SANDBOX" is the old free arena (tests, free ride).

signal interacted(npc_id: String)

var world: WorldBuilder
var player: Player
var rig: CameraRig
var hud: Hud
var dialogue: DialogueBox
var touch: TouchControls
var companion: Companion
var runner: MissionRunner
var narayana: Node3D
var npcs: Dictionary = {}
var quest_npc: String = ""
var play: Dictionary = {}
var sandbox: bool = true
var spawn_timer: float = 2.0
var spawn_rule: Dictionary = {}
var spawner_on: bool = false
var rng := RandomNumberGenerator.new()
var seed_counter: int = 100
var boss_spawned: bool = false
var bounds: float = 150.0
var mission_done: bool = false
var _flash: ColorRect


func _ready() -> void:
	Player.ensure_input()
	Game.reset()
	Sfx.refresh()
	rng.seed = 7
	sandbox = Campaign.current == Campaign.SANDBOX
	play = {} if sandbox else Campaign.play_block(Campaign.current)
	Game.mission_mode = not sandbox
	if sandbox:
		await _ready_sandbox()
	else:
		await _ready_mission()


# ================================================================== sandbox (old free arena)
func _ready_sandbox() -> void:
	world = WorldBuilder.new()
	add_child(world)
	_make_player("mounted", Vector3.ZERO, 0.0)
	_make_companion()
	_make_camera_and_input()
	_spawn_narayana()
	for i in 3:
		spawn_enemy("raider", 26.0 + i * 4.0)
	if not Game.demo and not Game.skip_title:
		get_tree().paused = true
		var title := TitleScreen.new()
		add_child(title)
		await title.started
		if OS.get_environment("KALKI_NOPROLOGUE") == "":
			var pro := Prologue.new()
			add_child(pro)
			await pro.finished
		get_tree().paused = false
	Game.skip_title = true
	hud = Hud.new()   # built after the title so it uses the language chosen there
	hud.player = player
	add_child(hud)
	spawner_on = true
	await get_tree().create_timer(0.8).timeout
	Game.say("narayana_intro")
	await get_tree().create_timer(7.0).timeout
	_vanish_narayana()
	Game.say("shuka_start")
	Game.victory.connect(_appear_narayana)


# ================================================================== missions
func _ready_mission() -> void:
	var id := Campaign.current
	var info := Campaign.mission(id)
	if play.get("cine", "") == "prologue":
		await _cinematic_mission(id)
		return
	Game.dharma = float(play.get("dharma", 40.0))
	world = WorldBuilder.new()
	var wcfg: Dictionary = play.get("world", {}).duplicate()
	wcfg["biome"] = play.get("biome", "shambhala")
	world.config = wcfg
	add_child(world)
	bounds = float(play.get("bounds", 110.0))
	var st: Array = play.get("start", [0, 12])
	_make_player(str(play.get("mode", "foot")), Vector3(float(st[0]), 0, float(st[1])), float(play.get("yaw", 0.0)))
	if Campaign.has_flag("has_shuka") and play.get("shuka", true):
		_make_companion()
	_make_camera_and_input()
	for cfg in play.get("npcs", []):
		var n := Npc.new()
		n.setup(cfg)
		n.face_target = player
		add_child(n)
		npcs[str(cfg["id"])] = n
	hud = Hud.new()
	hud.player = player
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	hud.set_dharma_visible(bool(play.get("dharma_ui", false)))
	dialogue = DialogueBox.new()
	add_child(dialogue)
	Game.player_died.connect(_on_player_died)
	hud.result_choice.connect(_on_result_choice)
	if play.has("spawner"):
		spawn_rule = play["spawner"]
	runner = MissionRunner.new()
	runner.m = self
	add_child(runner)
	await get_tree().create_timer(0.4).timeout
	hud.show_banner("%s\n%s" % [id, Game.mission_title(info)], 3.0)
	await get_tree().create_timer(2.2).timeout
	if play.has("intro"):
		await say(play["intro"])
	spawner_on = play.has("spawner") and bool(play.get("spawner_from_start", false))
	await runner.run(play.get("objectives", []))
	await _finish_mission()


func _cinematic_mission(id: String) -> void:
	world = WorldBuilder.new()
	world.config = {"biome": "vision", "village": false, "pillars": false}
	add_child(world)
	_make_player("foot", Vector3(0, 0, 0), 0.0)
	player.visible = false
	_make_camera_and_input()
	hud = Hud.new()
	hud.player = player
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	hud.set_dharma_visible(false)
	var pro := Prologue.new()
	add_child(pro)
	await pro.finished
	pro.queue_free()
	await _finish_mission()


func _finish_mission() -> void:
	if mission_done:
		return
	mission_done = true
	var id := Campaign.current
	Campaign.complete(id)
	if play.has("outro"):
		await say(play["outro"])
	for f in play.get("grant", []):
		Campaign.set_flag(str(f))
	var nxt := Campaign.next_id(id)
	var buttons: Array = []
	if nxt != "":
		buttons.append({"id": "next", "text": Game.t("btn_next")})
	buttons.append({"id": "replay", "text": Game.t("btn_replay")})
	buttons.append({"id": "menu", "text": Game.t("btn_menu")})
	hud.show_result("%s\n%s" % [Game.t("mission_complete"), Game.mission_title(Campaign.mission(id))], buttons)
	get_tree().paused = true


func _on_player_died() -> void:
	if mission_done:
		return
	runner.cancelled = true
	await get_tree().create_timer(1.4).timeout
	hud.show_result(Game.t("mission_failed"), [{"id": "replay", "text": Game.t("btn_retry")}, {"id": "menu", "text": Game.t("btn_menu")}])


func _on_result_choice(choice: String) -> void:
	get_tree().paused = false
	match choice:
		"next": Campaign.start(Campaign.next_id(Campaign.current))
		"replay": Campaign.start(Campaign.current)
		"resume": hud.hide_result()
		"menu": go_menu()


func go_menu() -> void:
	get_tree().paused = false
	Game.reset()
	Game.mission_mode = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


# ================================================================== building blocks
func _make_player(mode: String, pos: Vector3, yaw: float) -> void:
	var p := Player.new()
	p.mode = mode
	p.height_override = float(play.get("player_h", 0.0))
	p.bounds = bounds if not sandbox else 150.0
	add_child(p)
	p.global_position = pos
	p.yaw = yaw
	p.rotation.y = yaw
	if player:
		p.hp = player.hp
	player = p


func _make_companion() -> void:
	if companion:
		return
	companion = Companion.new()
	companion.target = player
	add_child(companion)
	companion.global_position = player.global_position + Vector3(-1.4, 2.4, 0.6)


func _make_camera_and_input() -> void:
	rig = CameraRig.new()
	add_child(rig)
	rig.target = player
	rig.global_position = player.global_position + Vector3(0, 2, 8)
	player.shake.connect(rig.add_shake)
	if player.mode == "foot":
		rig.distance = 7.5
	if DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or OS.get_environment("KALKI_TOUCH") != "":
		touch = TouchControls.new()
		add_child(touch)
		touch.camera_drag.connect(rig.drag)
		world.sun.shadow_enabled = false   # keep phones smooth
		rig.distance = 11.0 if player.mode == "mounted" else 8.5


func swap_player(mode: String) -> void:
	if player.mode == mode:
		return
	var old := player
	var pos := old.global_position
	var yaw := old.yaw
	_flash_at(pos)
	old.queue_free()
	player = null
	_make_player(mode, pos, yaw)
	player.hp = old.hp
	rig.target = player
	player.shake.connect(rig.add_shake)
	rig.distance = 11.0 if mode == "mounted" else 7.5
	if companion:
		companion.target = player
	hud.player = player
	Sfx.play("fanfare", -6.0)
	await get_tree().create_timer(0.6).timeout


func say(lines: Array) -> void:
	if lines.is_empty() or dialogue == null:
		return
	await dialogue.play(lines)


func set_dharma(v: float) -> void:
	Game.dharma = v
	Game.dharma_changed.emit(v)


func open_codex(entry: String) -> void:
	var cx := Codex.new()
	add_child(cx)
	cx.show_entry(entry)
	await cx.closed
	cx.queue_free()
	Campaign.mark_codex(entry)


# ---- enemies
func spawn_enemy(kind: String, dist: float) -> Enemy:
	var a := rng.randf() * TAU
	var pos := player.global_position + Vector3(cos(a), 0, sin(a)) * dist
	return spawn_enemy_at(kind, pos)


func spawn_enemy_at(kind: String, pos: Vector3) -> Enemy:
	var flat := Vector2(pos.x, pos.z)
	var lim := bounds * 0.94
	if flat.length() > lim:
		flat = flat.normalized() * lim
		pos = Vector3(flat.x, 0, flat.y)
	var e := Enemy.new()
	seed_counter += 1
	e.setup(kind, pos, player, seed_counter)
	add_child(e)
	return e


## spec: [{kind, n, radius?, pos?: [x, z]}]
func spawn_group(spec: Array) -> Array:
	var out: Array = []
	for s in spec:
		for i in int(s.get("n", 1)):
			if s.has("pos"):
				var c: Array = s["pos"]
				var o := Vector3(rng.randf_range(-3, 3), 0, rng.randf_range(-3, 3))
				out.append(spawn_enemy_at(str(s["kind"]), Vector3(float(c[0]), 0, float(c[1])) + o))
			else:
				out.append(spawn_enemy(str(s["kind"]), float(s.get("radius", 24.0)) + rng.randf_range(-3.0, 5.0)))
	return out


func _spawner(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	var rule: Dictionary = spawn_rule
	if rule.is_empty():
		for r in Game.world_cfg["spawn_table"]:
			if Game.dharma >= float(r["from"]):
				rule = r
	spawn_timer = float(rule.get("interval", 3.0))
	var cap := 3 if get_tree().get_nodes_in_group("boss").size() > 0 else int(rule.get("max_alive", rule.get("max", 4)))
	if get_tree().get_nodes_in_group("enemies").size() >= cap:
		return
	var weights: Dictionary = rule["weights"]
	var total := 0.0
	for k in weights:
		total += float(weights[k])
	var pick := rng.randf() * total
	var kind := "raider"
	for k in weights:
		pick -= float(weights[k])
		if pick <= 0.0:
			kind = k
			break
	spawn_enemy(kind, rng.randf_range(32.0, 46.0))


func _spawn_twins() -> void:
	boss_spawned = true
	var a := spawn_enemy("koka", 34.0)
	var b := spawn_enemy("vikoka", 38.0)
	a.twin = b
	b.twin = a
	Game.say("boss_intro")


# ---- markers and effects (light and particles, not props)
func beacon(pos: Vector3, col: Color) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	var sparks := CPUParticles3D.new()
	sparks.amount = 40
	sparks.lifetime = 2.2
	sparks.preprocess = 2.0
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = 0.9
	sparks.direction = Vector3.UP
	sparks.spread = 4.0
	sparks.initial_velocity_min = 1.5
	sparks.initial_velocity_max = 3.0
	sparks.gravity = Vector3.ZERO
	var sm := SphereMesh.new()
	sm.radius = 0.06
	sm.height = 0.12
	var smat := StandardMaterial3D.new()
	smat.albedo_color = col
	smat.emission_enabled = true
	smat.emission = col
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = smat
	sparks.mesh = sm
	n.add_child(sparks)
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 1.5
	tm.outer_radius = 1.65
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(col.r, col.g, col.b, 0.8)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.emission_enabled = true
	rm.emission = col
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tm.material = rm
	ring.mesh = tm
	ring.position.y = 0.08
	n.add_child(ring)
	var l := OmniLight3D.new()
	l.light_color = col
	l.light_energy = 1.6
	l.omni_range = 7.0
	l.position.y = 2.0
	n.add_child(l)
	add_child(n)
	return n


func ring_marker(pos: Vector3) -> Node3D:
	var n := beacon(pos, Color(0.5, 0.9, 1.0))
	var big := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 3.4
	tm.outer_radius = 3.6
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(0.6, 0.95, 1.0, 0.7)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.emission_enabled = true
	rm.emission = Color(0.5, 0.9, 1.0)
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tm.material = rm
	big.mesh = tm
	big.rotation.x = PI / 2.0
	big.position.y = 2.2
	n.add_child(big)
	return n


func mist(pos: Vector3, r: float) -> Node3D:
	var p := CPUParticles3D.new()
	p.position = pos + Vector3(0, 0.6, 0)
	p.amount = int(clampf(r * 14.0, 40, 220))
	p.lifetime = 4.0
	p.preprocess = 4.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = r * 0.85
	p.direction = Vector3.UP
	p.spread = 30.0
	p.initial_velocity_min = 0.1
	p.initial_velocity_max = 0.5
	p.gravity = Vector3.ZERO
	p.scale_amount_min = 1.0
	p.scale_amount_max = 3.2
	var q := SphereMesh.new()
	q.radius = 0.6
	q.height = 1.2
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.85, 0.35, 0.18)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	q.material = mat
	p.mesh = q
	add_child(p)
	return p


func restore_fx(pos: Vector3) -> void:
	_flash_at(pos)
	Sfx.play("chime", -2.0)
	rig.add_shake(0.2)


func _flash_at(pos: Vector3) -> void:
	var m := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 1.0
	s.height = 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.9, 0.5, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.85, 0.4)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	s.material = mat
	m.mesh = s
	add_child(m)
	m.global_position = pos + Vector3(0, 1.2, 0)
	m.scale = Vector3.ONE * 0.3
	var tw := m.create_tween()
	tw.set_parallel(true)
	tw.tween_property(m, "scale", Vector3.ONE * 5.0, 0.7)
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.7)
	tw.chain().tween_callback(m.queue_free)


# ---- story effects
func fx_gift() -> void:
	_flash_at(player.global_position)
	Sfx.play("fanfare", -4.0)
	if player.mode == "foot" and player.sword == null:
		Campaign.set_flag("has_sword")
		player.sword = Props.arm_with_sword(player.model)
	Campaign.set_flag("has_horse")
	Campaign.set_flag("has_shuka")
	_make_companion()
	await get_tree().create_timer(1.6).timeout


func fx_scout(path: Array) -> void:
	if companion == null:
		return
	rig.target = companion
	await companion.fly_path(path)
	rig.target = player


func fx_chariot() -> void:
	var f := Vector3(-sin(player.yaw), 0, -cos(player.yaw))
	var pos := player.global_position + f * 14.0
	var ch := Props.character("surya", 4.2)
	if ch:
		ch.position = pos
		ch.rotation.y = player.yaw
		add_child(ch)
		var l := OmniLight3D.new()
		l.light_color = Color(1.0, 0.85, 0.4)
		l.light_energy = 3.0
		l.omni_range = 16.0
		l.position = Vector3(0, 3.0, 0)
		ch.add_child(l)
	_flash_at(pos)
	Sfx.play("fanfare", -4.0)
	await get_tree().create_timer(2.0).timeout


func fx_dawn() -> void:
	var tw := create_tween()
	tw.tween_method(func(v: float): set_dharma(v), Game.dharma, 100.0, 4.0)
	hud.show_banner(Game.t("satya_dawn"), 3.0)
	Sfx.play("fanfare", -3.0)
	await tw.finished
	await get_tree().create_timer(1.0).timeout


func fx_brahmastra() -> void:
	_screen_flash(Color(1, 1, 1, 1), 0.9)
	Sfx.play("boom", 0.0, 0.02)
	rig.add_shake(1.0)
	await get_tree().create_timer(0.5).timeout
	for e in get_tree().get_nodes_in_group("enemies"):
		e.take_damage(9999.0, player.global_position, 10.0, 0.0)
	await get_tree().create_timer(1.0).timeout


func fx_fade(secs: float) -> void:
	_screen_flash(Color(0, 0, 0, 1), secs)
	await get_tree().create_timer(secs).timeout


func _screen_flash(col: Color, secs: float) -> void:
	if _flash == null:
		var cl := CanvasLayer.new()
		cl.layer = 90
		cl.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(cl)
		_flash = ColorRect.new()
		_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
		_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cl.add_child(_flash)
	_flash.color = Color(col.r, col.g, col.b, 0.0)
	var tw := create_tween()
	tw.tween_property(_flash, "color:a", 1.0, secs * 0.35)
	tw.tween_property(_flash, "color:a", 0.0, secs * 0.65)


# ================================================================== sandbox cameos (unchanged)
func _spawn_narayana() -> void:
	var scene: PackedScene = load("res://assets/models/narayana.glb")
	narayana = scene.instantiate()
	narayana.scale = Vector3.ONE * 1.9
	narayana.position = Vector3(0, 0, -11)
	add_child(narayana)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.4)
	light.light_energy = 2.5
	light.omni_range = 16.0
	light.position = Vector3(0, 2.5, 1.5)
	narayana.add_child(light)


func _vanish_narayana() -> void:
	if narayana == null:
		return
	var tw := create_tween()
	tw.tween_property(narayana, "scale", Vector3.ONE * 0.01, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): narayana.visible = false)


func _appear_narayana() -> void:
	if narayana == null:
		return
	narayana.visible = true
	narayana.position = player.global_position + Vector3(-sin(player.yaw), 0, -cos(player.yaw)) * 12.0
	narayana.rotation.y = atan2(player.global_position.x - narayana.position.x, player.global_position.z - narayana.position.z)
	narayana.scale = Vector3.ONE * 0.01
	var tw := create_tween()
	tw.tween_property(narayana, "scale", Vector3.ONE * 1.9, 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for e in get_tree().get_nodes_in_group("enemies"):
		e.take_damage(9999.0, player.global_position, 4.0, 0.0)


# ================================================================== per-frame
func _process(delta: float) -> void:
	if narayana and narayana.visible:
		narayana.position.y = 0.25 + sin(Time.get_ticks_msec() * 0.0015) * 0.15
	if sandbox:
		if Input.is_action_just_pressed("restart"):
			Game.reset()
			get_tree().reload_current_scene()
		if Game.finished or player.state == "dead" or hud == null:
			return
		if not boss_spawned and Game.dharma >= 80.0:
			_spawn_twins()
		if spawner_on:
			_spawner(delta)
		return
	if hud == null or player == null or dialogue == null:
		return
	if Input.is_action_just_pressed("restart") and not mission_done:
		Campaign.start(Campaign.current)
		return
	if Input.is_action_just_pressed("ui_cancel") and not mission_done and not dialogue.is_active():
		get_tree().paused = true
		hud.show_result(Game.t("paused"), [{"id": "resume", "text": Game.t("btn_resume")}, {"id": "menu", "text": Game.t("btn_menu")}])
	if spawner_on and player.state != "dead":
		_spawner(delta)
	_update_interaction()


func _update_interaction() -> void:
	var near: Npc = null
	var best := 1e9
	if not dialogue.is_active() and player.state != "dead":
		for n in npcs.values():
			if not n.visible:
				continue
			var d: float = n.distance_to(player.global_position)
			if d < n.talk_radius and d < best:
				near = n
				best = d
	var talkable: bool = near != null and (near.npc_id == quest_npc or play.get("chat", {}).has(near.npc_id))
	if talkable:
		hud.set_prompt(Game.t("prompt_talk") % Game.t(near.display_key))
	else:
		hud.set_prompt("")
	if touch:
		touch.set_talk(talkable)
	if talkable and Input.is_action_just_pressed("interact"):
		Input.action_release("interact")
		if near.npc_id == quest_npc:
			interacted.emit(near.npc_id)
		else:
			await say(play["chat"][near.npc_id])
