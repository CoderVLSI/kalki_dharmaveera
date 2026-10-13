class_name MissionRunner
extends Node
## Runs a mission's objective list in order (data: missions.json -> play.objectives).
## Objective types: talk, reach, defeat, rings, collect, boss, cutscene, choice, survive, codex,
## restore, mount, wait. Every objective may carry pre/post dialogue lines, a HUD text key,
## `flags` to set when it ends and `dharma` to set when it starts.

var m: Node3D            # the mission host (main.gd)
var cancelled: bool = false
var hazards: Array = []  # [{pos: Vector3, r: float, node: Node3D}]
var _hazard_t: float = 0.0


func run(objs: Array) -> void:
	for i in objs.size():
		if cancelled:
			return
		await _run_one(objs[i])


func _process(delta: float) -> void:
	if hazards.is_empty() or m == null or m.player == null or m.player.state == "dead":
		return
	_hazard_t -= delta
	if _hazard_t > 0.0:
		return
	_hazard_t = 0.8
	for h in hazards:
		if Vector2(m.player.global_position.x - h.pos.x, m.player.global_position.z - h.pos.z).length() < float(h.r):
			m.player.take_damage(float(h.get("dmg", 5.0)), h.pos)


func _frames() -> void:
	if Campaign.autoplay:
		for e in get_tree().get_nodes_in_group("enemies"):
			e.take_damage(9999.0, m.player.global_position, 0.0, 0.0)
	await get_tree().process_frame


func _dist(p: Vector3) -> float:
	if Campaign.autoplay and m.player:
		m.player.global_position = Vector3(p.x, 0, p.z)
		return 0.0
	return Vector2(m.player.global_position.x - p.x, m.player.global_position.z - p.z).length()


func _vec(a: Array) -> Vector3:
	return Vector3(float(a[0]), 0.0, float(a[1]))


func _run_one(o: Dictionary) -> void:
	if o.has("dharma"):
		m.set_dharma(float(o["dharma"]))
	if o.has("pre"):
		await m.say(o["pre"])
	var text := Game.t(str(o.get("text", ""))) if o.has("text") else ""
	m.hud.set_objective(text)
	match str(o.get("type", "wait")):
		"talk": await _talk(o, text)
		"reach": await _reach(o, text)
		"defeat": await _defeat(o, text)
		"rings": await _rings(o, text)
		"collect": await _collect(o, text)
		"boss": await _boss(o, text)
		"cutscene": await _cutscene(o)
		"choice": await _choice(o)
		"survive": await _survive(o, text)
		"codex": await m.open_codex(str(o["entry"]))
		"restore": await _restore(o, text)
		"mount": await m.swap_player("mounted")
		"wait": await get_tree().create_timer(float(o.get("secs", 1.0))).timeout
	m.hud.set_objective("")
	if o.has("post"):
		await m.say(o["post"])
	for f in o.get("flags", []):
		Campaign.set_flag(str(f))


# ---------------------------------------------------------------- objective types
func _talk(o: Dictionary, text: String) -> void:
	var npc: Npc = m.npcs.get(str(o["npc"]))
	if npc == null:
		push_warning("talk: no npc " + str(o["npc"]))
		return
	npc.set_marker(true)
	m.quest_npc = str(o["npc"])
	if Campaign.autoplay:
		get_tree().create_timer(0.1).timeout.connect(func(): m.interacted.emit(str(o["npc"])))
	while true:
		var id: String = await m.interacted
		if id == m.quest_npc:
			break
	m.quest_npc = ""
	npc.set_marker(false)
	await m.say(o.get("lines", []))


func _reach(o: Dictionary, text: String) -> void:
	var p := _vec(o["pos"])
	var r := float(o.get("r", 4.0))
	var b: Node3D = m.beacon(p, Color(1.0, 0.85, 0.3))
	var tick := 0.0
	while _dist(p) > r:
		tick -= get_process_delta_time()
		if tick <= 0.0:
			tick = 0.3
			m.hud.set_objective(text, 0, 0, "%d m" % int(_dist(p)))
		await _frames()
	b.queue_free()
	Sfx.play("chime", -6.0)


func _alive(list: Array) -> Array:
	return list.filter(func(e): return is_instance_valid(e) and e.is_in_group("enemies"))


func _defeat(o: Dictionary, text: String) -> void:
	var all: Array = []
	var waves: Array = o.get("waves", [o.get("spawn", [])])
	if o.has("hide_npc") and m.npcs.has(str(o["hide_npc"])):
		m.npcs[str(o["hide_npc"])].visible = false
	for wi in waves.size():
		var group: Array = m.spawn_group(waves[wi])
		all.append_array(group)
		if wi < waves.size() - 1:
			# next wave comes when the current one is nearly done (or after a delay)
			var t := 0.0
			while _alive(group).size() > maxi(1, int(group.size() * 0.3)) and t < float(o.get("wave_gap", 25.0)):
				t += get_process_delta_time()
				m.hud.set_objective(text, all.size() - _alive(all).size(), all.size() + 0)
				await _frames()
	var total := all.size()
	while not _alive(all).is_empty():
		m.hud.set_objective(text, total - _alive(all).size(), total)
		if m.player.state == "dead":
			return
		await _frames()
	if o.has("hide_npc") and m.npcs.has(str(o["hide_npc"])):
		var n: Npc = m.npcs[str(o["hide_npc"])]
		n.visible = true
		if o.has("npc_at") and all.size() > 0:
			n.global_position = Vector3(all[0].global_position.x, 0, all[0].global_position.z)


func _rings(o: Dictionary, text: String) -> void:
	var pts: Array = o["points"]
	for i in pts.size():
		var p := _vec(pts[i])
		var ring: Node3D = m.ring_marker(p)
		while _dist(p) > float(o.get("r", 4.5)):
			m.hud.set_objective(text, i, pts.size(), "%d m" % int(_dist(p)))
			await _frames()
		ring.queue_free()
		Sfx.play("chime", -5.0)
	m.hud.set_objective(text, pts.size(), pts.size())


func _collect(o: Dictionary, text: String) -> void:
	var pts: Array = o["items"]
	var items: Array = []
	for pt in pts:
		var n := Props.spawn(str(o.get("model", "prop_lotus")))
		if n == null:
			continue
		n.position = _vec(pt) + Vector3(0, 0.6, 0)
		n.scale = Vector3.ONE * float(o.get("scale", 2.4))
		m.add_child(n)
		var glow := OmniLight3D.new()
		glow.light_color = Color(1.0, 0.8, 0.9)
		glow.light_energy = 1.2
		glow.omni_range = 5.0
		glow.position.y = 1.0
		n.add_child(glow)
		items.append(n)
	for hz in o.get("hazards", []):
		var pos := _vec(hz["pos"])
		hazards.append({"pos": pos, "r": float(hz["r"]), "dmg": float(hz.get("dmg", 5.0)), "node": m.mist(pos, float(hz["r"]))})
	var total := items.size()
	var got := 0
	while got < total:
		for it in items.duplicate():
			if not is_instance_valid(it):
				continue
			it.rotation.y += get_process_delta_time()
			if _dist(it.global_position) < float(o.get("pick_r", 2.4)):
				items.erase(it)
				it.queue_free()
				got += 1
				Sfx.play("chime", -3.0)
				if o.has("gain"):
					Game.add_dharma(float(o["gain"]))
				m.hud.set_objective(text, got, total)
		if m.player.state == "dead":
			break
		await _frames()
	for h in hazards:
		if is_instance_valid(h.node):
			h.node.queue_free()
	hazards.clear()


func _boss(o: Dictionary, text: String) -> void:
	var spawned: Array = []
	var kinds: Array = o["kinds"]
	var dist := float(o.get("dist", 30.0))
	for k in kinds:
		var e: Enemy = m.spawn_enemy(str(k), dist + spawned.size() * 4.0)
		spawned.append(e)
	if kinds.has("koka") and kinds.has("vikoka"):
		spawned[0].twin = spawned[1]
		spawned[1].twin = spawned[0]
	if o.has("intro"):
		await m.say(o["intro"])
	while not _alive(spawned).is_empty():
		if m.player.state == "dead":
			return
		m.hud.set_objective(text, spawned.size() - _alive(spawned).size(), spawned.size())
		await _frames()


func _cutscene(o: Dictionary) -> void:
	if o.has("lines"):
		await m.say(o["lines"])
	match str(o.get("effect", "")):
		"gift": await m.fx_gift()
		"scout": await m.fx_scout(o.get("path", []))
		"chariot": await m.fx_chariot()
		"dawn": await m.fx_dawn()
		"brahmastra": await m.fx_brahmastra()
		"fade": await m.fx_fade(float(o.get("secs", 1.5)))
		"": pass


func _choice(o: Dictionary) -> void:
	var opts: Array = o["options"]
	for attempt in 3:
		var idx: int = await m.dialogue.choose(str(o["prompt"]), opts)
		if idx < 0:
			idx = 0
		var opt: Dictionary = opts[idx]
		if opt.has("lines"):
			await m.say(opt["lines"])
		if bool(opt.get("correct", false)) or attempt == 2:
			return


func _survive(o: Dictionary, text: String) -> void:
	var t := float(o.get("secs", 40.0))
	var every := float(o.get("every", 8.0))
	var next := 0.0
	while t > 0.0:
		var dt := get_process_delta_time()
		t -= dt
		next -= dt
		if next <= 0.0:
			next = every
			m.spawn_group(o.get("spawn", []))
		m.hud.set_objective(text, 0, 0, "%d s" % int(t))
		if m.player.state == "dead":
			return
		await _frames()
	for e in m.get_tree().get_nodes_in_group("enemies"):
		e.take_damage(9999.0, m.player.global_position, 4.0, 0.0)


func _restore(o: Dictionary, text: String) -> void:
	var pts: Array = o["points"]
	var done := 0
	var beacons: Array = []
	for pt in pts:
		beacons.append(m.beacon(_vec(pt), Color(0.6, 1.0, 0.6)))
	while done < pts.size():
		for i in pts.size():
			if beacons[i] == null or not is_instance_valid(beacons[i]):
				continue
			if _dist(_vec(pts[i])) < float(o.get("r", 5.0)):
				beacons[i].queue_free()
				beacons[i] = null
				done += 1
				Game.add_dharma(float(o.get("gain", 20.0)))
				m.restore_fx(_vec(pts[i]))
				m.hud.set_objective(text, done, pts.size())
				if o.has("lines_each") and done <= o["lines_each"].size():
					await m.say([o["lines_each"][done - 1]])
		await _frames()
