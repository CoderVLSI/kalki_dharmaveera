class_name Enemy
extends Node3D
## Rule-based unit of Kali's host. Behaviour comes from data/enemies.json.
## States: patrol -> chase -> windup -> recover, flee, stunned, dead.
## All visuals are placeholder primitives (tier: invented).

var kind: String = "raider"
var cfg: Dictionary = {}
var player: Node3D
var hp: float = 60.0
var max_hp: float = 60.0
var state: String = "patrol"
var home: Vector3
var wander_dir: Vector3 = Vector3.ZERO
var wander_t: float = 0.0
var timer: float = 0.0
var cd: float = 1.0
var stun: float = 0.0
var knock: Vector3 = Vector3.ZERO
var flee_t: float = 0.0
var buffed: bool = false
var buff_scan: float = 0.0
var rng := RandomNumberGenerator.new()
var body_mat: StandardMaterial3D
var arm_pivot: Node3D
var label: Label3D
var visual: Node3D
var aim_marker: MeshInstance3D
var base_color: Color
var strike_done: bool = false
var twin: Enemy
var down_t: float = 0.0


func setup(k: String, pos: Vector3, p: Node3D, seed_value: int) -> void:
	kind = k
	cfg = Game.enemies_cfg[k]
	player = p
	rng.seed = seed_value
	max_hp = float(cfg["hp"])
	hp = max_hp
	position = pos
	home = pos
	cd = rng.randf_range(0.5, 1.5)


func _ready() -> void:
	add_to_group("enemies")
	if kind == "koka" or kind == "vikoka":
		add_to_group("boss")
	_build_visual()
	_update_label()


func _build_visual() -> void:
	var c: Array = cfg["color"]
	base_color = Color(c[0], c[1], c[2])
	visual = Node3D.new()
	visual.scale = Vector3.ONE * float(cfg["scale"])
	add_child(visual)
	body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = base_color
	body_mat.roughness = 0.8
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.22, 0.14, 0.12)
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.18, 0.18, 0.2)
	metal.metallic = 0.7
	metal.roughness = 0.4

	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.42
	cap.height = 1.7
	cap.material = body_mat
	body.mesh = cap
	body.position.y = 0.9
	visual.add_child(body)

	var head := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.27
	sph.height = 0.54
	sph.material = skin
	head.mesh = sph
	head.position.y = 1.95
	visual.add_child(head)

	var helm := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.3
	cone.height = 0.5
	cone.material = metal
	helm.mesh = cone
	helm.position.y = 2.28
	visual.add_child(helm)

	# glowing eyes so Kali's host reads as menacing in the ash light
	var eyes := MeshInstance3D.new()
	var eb := BoxMesh.new()
	eb.size = Vector3(0.36, 0.06, 0.05)
	var em := StandardMaterial3D.new()
	em.albedo_color = Color(1.0, 0.25, 0.1)
	em.emission_enabled = true
	em.emission = Color(1.0, 0.2, 0.05)
	em.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eb.material = em
	eyes.mesh = eb
	eyes.position = Vector3(0, 1.98, -0.24)
	visual.add_child(eyes)

	arm_pivot = Node3D.new()
	arm_pivot.position = Vector3(0.5, 1.5, 0)
	visual.add_child(arm_pivot)
	var weapon := MeshInstance3D.new()
	var wb := BoxMesh.new()
	match kind:
		"archer": wb.size = Vector3(0.06, 1.3, 0.2)   # bow
		"banner": wb.size = Vector3(0.08, 2.8, 0.08)  # pole
		_: wb.size = Vector3(0.1, 1.5, 0.1)          # blade
	wb.material = metal
	weapon.mesh = wb
	weapon.position = Vector3(0, -0.2, -0.45) if kind != "banner" else Vector3(0, 0.4, 0)
	weapon.rotation.x = deg_to_rad(80) if kind != "banner" else 0.0
	arm_pivot.add_child(weapon)
	if kind == "banner":
		var cloth := MeshInstance3D.new()
		var cb := BoxMesh.new()
		cb.size = Vector3(0.9, 0.9, 0.04)
		var cm := StandardMaterial3D.new()
		cm.albedo_color = Color(0.7, 0.05, 0.05)
		cm.emission_enabled = true
		cm.emission = Color(0.6, 0.0, 0.0)
		cb.material = cm
		cloth.mesh = cb
		cloth.position = Vector3(0.5, 1.4, 0)
		weapon.add_child(cloth)
		var aura := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = float(cfg["buff_radius"]) - 0.15
		tm.outer_radius = float(cfg["buff_radius"])
		var am := StandardMaterial3D.new()
		am.albedo_color = Color(0.9, 0.1, 0.1, 0.35)
		am.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		am.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tm.material = am
		aura.mesh = tm
		aura.position.y = 0.05
		add_child(aura)

	aim_marker = MeshInstance3D.new()
	var ab := SphereMesh.new()
	ab.radius = 0.22
	ab.height = 0.44
	var amat := StandardMaterial3D.new()
	amat.albedo_color = Color(1.0, 0.9, 0.2)
	amat.emission_enabled = true
	amat.emission = Color(1.0, 0.8, 0.1)
	amat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ab.material = amat
	aim_marker.mesh = ab
	aim_marker.position.y = 3.0
	aim_marker.visible = false
	add_child(aim_marker)

	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 3.2 * float(cfg["scale"]) + float(get_instance_id() % 3) * 0.55
	label.pixel_size = 0.012
	label.font_size = 28
	label.outline_size = 8
	add_child(label)


func _update_label() -> void:
	if state == "downed":
		var other: String = twin.cfg["name"] if is_instance_valid(twin) else "his brother"
		label.text = "%s has fallen\nstrike %s NOW" % [cfg["name"], other]
		return
	var n := int(round(clampf(hp / max_hp, 0.0, 1.0) * 8.0))
	label.text = "%s\n%s%s" % [cfg["name"], "▰".repeat(n), "▱".repeat(8 - n)]


func _physics_process(delta: float) -> void:
	if state == "dead" or player == null:
		return
	cd = maxf(0.0, cd - delta)
	if state == "downed":
		_downed(delta)
		return
	var pd := global_position.distance_to(player.global_position)
	label.visible = pd < 24.0 or hp < max_hp or is_in_group("boss")
	# knockback decays
	if knock.length() > 0.1:
		global_position += knock * delta
		knock = knock.move_toward(Vector3.ZERO, 30.0 * delta)
	if stun > 0.0:
		stun -= delta
		visual.rotation.z = sin(Time.get_ticks_msec() * 0.03) * 0.12
		return
	visual.rotation.z = 0.0
	if kind != "banner":
		buff_scan -= delta
		if buff_scan <= 0.0:
			buff_scan = 0.5
			buffed = _near_banner()
	var to := player.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	var speed := float(cfg["speed"]) * (float(Game.enemies_cfg["banner"]["buff_speed"]) if buffed else 1.0)

	match state:
		"patrol":
			wander_t -= delta
			if wander_t <= 0.0:
				wander_t = rng.randf_range(1.5, 3.5)
				wander_dir = Vector3(rng.randf_range(-1, 1), 0, rng.randf_range(-1, 1)).normalized()
				if global_position.distance_to(home) > 8.0:
					wander_dir = (home - global_position).normalized()
			_step(wander_dir, speed * 0.35, delta)
			if dist < float(cfg["notice"]):
				state = "chase"
		"chase":
			_chase(to, dist, speed, delta)
		"windup":
			timer -= delta
			_face(to, delta)
			var prog := 1.0 - timer / float(cfg["windup"])
			arm_pivot.rotation.x = lerpf(0.0, -2.2, clampf(prog, 0, 1))
			body_mat.albedo_color = base_color.lerp(Color(1, 0.85, 0.2), clampf(prog, 0, 1) * 0.6)
			if timer <= 0.0:
				_strike(dist)
		"recover":
			timer -= delta
			arm_pivot.rotation.x = lerpf(arm_pivot.rotation.x, 0.0, 8.0 * delta)
			body_mat.albedo_color = base_color
			aim_marker.visible = false
			if timer <= 0.0:
				state = "chase"
		"flee":
			flee_t -= delta
			_step(-to.normalized(), speed * 1.1, delta)
			if flee_t <= 0.0:
				state = "chase"


func _near_banner() -> bool:
	for e in get_tree().get_nodes_in_group("enemies"):
		if e != self and e.kind == "banner" and e.state != "dead":
			if e.global_position.distance_to(global_position) < float(Game.enemies_cfg["banner"]["buff_radius"]):
				return true
	return false


func _chase(to: Vector3, dist: float, speed: float, delta: float) -> void:
	var rng_attack := float(cfg["attack_range"])
	# morale rule: raiders break below 25% hp unless a banner steadies them
	if kind == "raider" and hp / max_hp < float(cfg["flee_hp_frac"]) and not buffed:
		state = "flee"
		flee_t = 3.0
		return
	match kind:
		"raider", "koka", "vikoka":
			if dist > rng_attack:
				_step(to.normalized(), speed, delta)
			else:
				_face(to, delta)
				if cd <= 0.0:
					_begin_windup()
		"archer":
			var pref := float(cfg["preferred_range"])
			if dist < pref - 4.0:
				_step(-to.normalized(), speed, delta)
			elif dist > pref + 4.0:
				_step(to.normalized(), speed, delta)
			else:
				_face(to, delta)
			if dist < rng_attack and cd <= 0.0:
				_begin_windup()
		"banner":
			# keeps its distance and trails the fight
			if dist < 16.0:
				_step(-to.normalized(), speed, delta)
			elif dist > 22.0:
				_step(to.normalized(), speed, delta)
			_face(to, delta)


func _begin_windup() -> void:
	state = "windup"
	timer = float(cfg["windup"])
	strike_done = false
	if kind == "archer":
		aim_marker.visible = true


func _strike(dist: float) -> void:
	state = "recover"
	timer = float(cfg["recover"])
	cd = float(cfg["recover"]) + 0.4
	arm_pivot.rotation.x = 1.0
	aim_marker.visible = false
	if kind == "raider" or kind == "koka" or kind == "vikoka":
		if dist <= float(cfg["attack_range"]) * 1.4:
			player.take_damage(float(cfg["damage"]), global_position)
	elif kind == "archer":
		Sfx.play("twang", -4.0, 0.1)
		var arrow := Projectile.new()
		get_parent().add_child(arrow)
		var from := global_position + Vector3(0, 1.8, 0)
		var target: Vector3 = player.global_position + Vector3(0, 1.4, 0)
		arrow.launch(from, (target - from).normalized(), float(cfg["damage"]), player)


func _step(dir: Vector3, spd: float, delta: float) -> void:
	if dir == Vector3.ZERO:
		return
	global_position += dir * spd * delta
	global_position.y = 0.0
	_face(dir, delta)


func _face(dir: Vector3, delta: float) -> void:
	if dir.length() < 0.01:
		return
	var target := atan2(-dir.x, -dir.z)
	rotation.y = lerp_angle(rotation.y, target, 1.0 - exp(-10.0 * delta))


func take_damage(amount: float, from: Vector3, knockback: float = 6.0, stun_time: float = 0.35) -> void:
	if state == "dead" or state == "downed":
		return
	hp -= amount
	var away := global_position - from
	away.y = 0.0
	knock = away.normalized() * knockback
	stun = stun_time
	if state == "windup":
		state = "recover"
		timer = 0.4
		aim_marker.visible = false
	if state == "patrol":
		state = "chase"
	_hit_flash()
	_sparks()
	Sfx.play("hit", -1.0, 0.1)
	_update_label()
	if hp <= 0.0:
		if _is_twin() and is_instance_valid(twin) and twin.state != "dead":
			_fall()
		else:
			_die()


func _is_twin() -> bool:
	return kind == "koka" or kind == "vikoka"


## Canon rule: each twin revives unless both are brought down together.
func _fall() -> void:
	hp = 0.0
	if twin.state == "downed":
		# both are down at once: slain for good
		Game.boss_defeated = true
		var brother := twin
		_die()
		brother._die()
		Game.say("boss_dead")
		return
	state = "downed"
	down_t = float(cfg["revive_window"])
	aim_marker.visible = false
	var tw := create_tween()
	tw.tween_property(visual, "rotation:x", deg_to_rad(-80.0), 0.3)
	_update_label()
	Game.say("boss_down")
	Game.add_dharma(0.0)


func _downed(delta: float) -> void:
	down_t -= delta
	if not is_instance_valid(twin) or twin.state == "dead":
		_die()
		return
	if down_t <= 0.0:
		hp = max_hp * 0.6
		state = "chase"
		var tw := create_tween()
		tw.tween_property(visual, "rotation:x", 0.0, 0.3)
		_update_label()
		Sfx.play("boom", -8.0, 0.05)


func _hit_flash() -> void:
	body_mat.albedo_color = Color(1, 1, 1)
	var tw := create_tween()
	tw.tween_property(body_mat, "albedo_color", base_color, 0.2)


func _sparks() -> void:
	var p := CPUParticles3D.new()
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 14
	p.lifetime = 0.45
	p.direction = Vector3(0, 1, 0)
	p.spread = 80.0
	p.initial_velocity_min = 3.0
	p.initial_velocity_max = 7.0
	p.gravity = Vector3(0, -12, 0)
	var m := SphereMesh.new()
	m.radius = 0.06
	m.height = 0.12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.8, 0.3)
	mat.emission_enabled = true
	mat.emission = Color(1, 0.7, 0.2)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.material = mat
	p.mesh = m
	get_parent().add_child(p)
	p.global_position = global_position + Vector3(0, 1.4, 0)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)


func _die() -> void:
	state = "dead"
	Sfx.play("die", -2.0, 0.12)
	remove_from_group("enemies")
	label.visible = false
	aim_marker.visible = false
	Game.kills += 1
	Game.enemy_killed.emit(kind)
	if kind == "banner":
		Game.say("banner_down")
	Game.add_dharma(float(cfg["dharma"]))
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "rotation:x", deg_to_rad(-85.0), 0.35)
	tw.tween_property(self, "scale", Vector3.ONE * 0.01, 0.9).set_delay(0.5)
	tw.chain().tween_callback(queue_free)
