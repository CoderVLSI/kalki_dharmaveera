class_name Player
extends Node3D
## Kalki on Devadatta. Rule-based controller: gait tiers, slash, rear-up Astra, dash.
## Forward is -Z. The glTF model faces +Z, so the model node is turned by PI.

signal shake(amount: float)

const MODEL_PATH := "res://assets/models/kalki_devadatta_rigged.glb"
const MODEL_SCALE := 1.6
const SPEEDS := {"walk": 3.5, "trot": 8.0, "gallop": 14.0}
const TURN := {"walk": 8.0, "trot": 5.5, "gallop": 3.2}
const SLASH_RANGE := 5.0
const SLASH_DAMAGE := 28.0
const SPECIAL_RADIUS := 11.0
const SPECIAL_DAMAGE := 48.0
const ARENA_RADIUS := 150.0
const LOOPING := ["idle", "walk", "trot", "gallop", "victory"]

var hp: float = 100.0
var max_hp: float = 100.0
var state: String = "free"          # free, slash, rear, dash, dead, victory
var gait: String = "idle"
var yaw: float = 0.0
var speed: float = 0.0
var special_cd: float = 0.0
var special_cd_max: float = 7.0
var dash_cd: float = 0.0
var invuln: float = 0.0
var state_time: float = 0.0
var state_len: float = 0.0
var hit_done: bool = false
var anim_test: bool = false
var test_name: String = ""
var model: Node3D
var anim: AnimationPlayer
var anim_names: Dictionary = {}
var cam: Camera3D
var dust: CPUParticles3D
var demo_t: float = 0.0
var step_t: float = 0.0
var _flash_mats: Array[StandardMaterial3D] = []


static func ensure_input() -> void:
	var map := {
		"move_forward": [KEY_W, KEY_UP], "move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"gallop": [KEY_SHIFT], "walk": [KEY_CTRL], "attack": [KEY_J],
		"special": [KEY_F, KEY_K], "dash": [KEY_SPACE],
		"cam_left": [KEY_Q], "cam_right": [KEY_E],
		"anim_toggle": [KEY_T], "restart": [KEY_R],
	}
	for action in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in map[action]:
				var ev := InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)


func _ready() -> void:
	add_to_group("player")
	ensure_input()
	var scene: PackedScene = load(MODEL_PATH)
	model = scene.instantiate()
	model.scale = Vector3.ONE * MODEL_SCALE
	model.rotation.y = PI
	add_child(model)
	var players := model.find_children("*", "AnimationPlayer", true, false)
	if players.size() > 0:
		anim = players[0]
		for n in anim.get_animation_list():
			var base := String(n).trim_suffix("-loop").trim_suffix("_loop")
			anim_names[base] = n
			anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR if base in LOOPING else Animation.LOOP_NONE
	else:
		push_warning("No AnimationPlayer found in model")
	_build_dust()
	Game.pillar_restored.connect(func(_id: String): heal(25.0))
	Game.victory.connect(_on_victory)
	_play("idle")
	Game.player_hp_changed.emit(hp, max_hp)


func _build_dust() -> void:
	dust = CPUParticles3D.new()
	dust.amount = 28
	dust.lifetime = 0.8
	dust.position = Vector3(0, 0.15, 1.6)
	dust.direction = Vector3(0, 1, 0.6)
	dust.spread = 35.0
	dust.initial_velocity_min = 1.5
	dust.initial_velocity_max = 3.0
	dust.gravity = Vector3(0, -0.4, 0)
	dust.scale_amount_min = 0.5
	dust.scale_amount_max = 1.3
	var m := SphereMesh.new()
	m.radius = 0.16
	m.height = 0.32
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.72, 0.64, 0.52, 0.45)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.material = mat
	dust.mesh = m
	dust.emitting = false
	add_child(dust)


# ------------------------------------------------------------------ animation
func _play(base: String, blend: float = 0.2, spd: float = 1.0) -> void:
	if anim == null or not anim_names.has(base):
		return
	var n: String = anim_names[base]
	if anim.current_animation != n or not anim.is_playing():
		anim.play(n, blend)
	anim.speed_scale = spd


func anim_length(base: String, spd: float = 1.0) -> float:
	if anim == null or not anim_names.has(base):
		return 0.6
	return anim.get_animation(anim_names[base]).length / spd


func test_play(base: String) -> void:
	anim_test = true
	test_name = base
	state = "free"
	speed = 0.0
	if anim:
		anim.stop()
	_play(base, 0.15)


func set_anim_test(on: bool) -> void:
	anim_test = on
	if on and test_name == "":
		test_name = "idle"
	if not on:
		state = "free"


# ------------------------------------------------------------------ main loop
func _physics_process(delta: float) -> void:
	special_cd = maxf(0.0, special_cd - delta)
	dash_cd = maxf(0.0, dash_cd - delta)
	invuln = maxf(0.0, invuln - delta)
	cam = get_viewport().get_camera_3d()
	if Game.demo:
		_demo(delta)
		return
	if state == "dead":
		return
	if Input.is_action_just_pressed("anim_toggle"):
		set_anim_test(not anim_test)
	if anim_test:
		if anim and not anim.is_playing() and test_name != "":
			_play(test_name, 0.1)
		dust.emitting = false
		return
	match state:
		"free": _state_free(delta)
		"slash": _state_slash(delta)
		"rear": _state_rear(delta)
		"dash": _state_dash(delta)
		"victory":
			dust.emitting = false


func _facing() -> Vector3:
	return Vector3(-sin(yaw), 0.0, -cos(yaw))


func _move(vel: Vector3, delta: float) -> void:
	global_position += vel * delta
	var flat := Vector2(global_position.x, global_position.z)
	if flat.length() > ARENA_RADIUS:
		flat = flat.normalized() * ARENA_RADIUS
		global_position = Vector3(flat.x, 0.0, flat.y)
	global_position.y = 0.0
	rotation.y = yaw


func _input_dir() -> Vector3:
	var inp := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if inp.length() < 0.1 or cam == null:
		return Vector3.ZERO
	var f := -cam.global_transform.basis.z
	f.y = 0.0
	f = f.normalized()
	var r := cam.global_transform.basis.x
	r.y = 0.0
	r = r.normalized()
	return (r * inp.x + f * -inp.y).normalized()


func _state_free(delta: float) -> void:
	var d := _input_dir()
	if d != Vector3.ZERO:
		gait = "gallop" if Input.is_action_pressed("gallop") else ("walk" if Input.is_action_pressed("walk") else "trot")
		var target := atan2(-d.x, -d.z)
		yaw = lerp_angle(yaw, target, 1.0 - exp(-float(TURN[gait]) * delta))
		var align := maxf(0.25, _facing().dot(d))
		speed = move_toward(speed, float(SPEEDS[gait]) * align, 40.0 * delta)
	else:
		gait = "idle"
		speed = move_toward(speed, 0.0, 30.0 * delta)
	_move(_facing() * speed, delta)
	if gait == "idle" and speed > 1.0:
		_play("trot", 0.2, 0.8)
	elif gait == "idle":
		_play("idle", 0.25)
	else:
		_play(gait, 0.18, clampf(speed / float(SPEEDS[gait]), 0.6, 1.3))
	dust.emitting = speed > 9.0
	if speed > 1.5:
		step_t += speed * delta
		var stride := 2.2 if gait == "walk" else (3.2 if gait == "trot" else 4.4)
		if step_t >= stride:
			step_t = 0.0
			Sfx.play("hoof", -7.0, 0.15)
	if Input.is_action_just_pressed("attack"):
		start_slash()
	elif Input.is_action_just_pressed("special"):
		start_special()
	elif Input.is_action_just_pressed("dash"):
		start_dash()


func start_slash() -> void:
	if state != "free" and state != "dash":
		return
	state = "slash"
	state_time = 0.0
	hit_done = false
	state_len = anim_length("slash", 1.7)
	if anim:
		anim.stop()
	_play("slash", 0.06, 1.7)
	Sfx.play("swish", -2.0)


func _state_slash(delta: float) -> void:
	state_time += delta
	var lunge := 7.0 if state_time < state_len * 0.5 else 2.0
	speed = lunge
	_move(_facing() * speed, delta)
	if not hit_done and state_time >= state_len * 0.42:
		hit_done = true
		_slash_hit()
	if state_time >= state_len:
		state = "free"


func _slash_hit() -> void:
	var hits := 0
	var fwd := _facing()
	for e in get_tree().get_nodes_in_group("enemies"):
		var to: Vector3 = e.global_position - global_position
		to.y = 0.0
		var dist := to.length()
		if dist < SLASH_RANGE and (dist < 1.8 or fwd.dot(to.normalized()) > 0.2):
			e.take_damage(SLASH_DAMAGE, global_position, 8.0)
			hits += 1
	_ring(SLASH_RANGE, Color(1.0, 0.85, 0.4, 0.8), 0.25, 1.4)
	shake.emit(0.25 if hits > 0 else 0.08)


func start_special() -> void:
	if state != "free" or special_cd > 0.0:
		return
	state = "rear"
	state_time = 0.0
	hit_done = false
	state_len = anim_length("rear")
	special_cd = special_cd_max
	invuln = maxf(invuln, state_len)
	speed = 0.0
	if anim:
		anim.stop()
	_play("rear", 0.08)


func _state_rear(delta: float) -> void:
	state_time += delta
	dust.emitting = false
	if not hit_done and state_time >= state_len * 0.42:
		hit_done = true
		for e in get_tree().get_nodes_in_group("enemies"):
			var d: float = e.global_position.distance_to(global_position)
			if d < SPECIAL_RADIUS:
				e.take_damage(SPECIAL_DAMAGE, global_position, 14.0, 1.6)
		_ring(SPECIAL_RADIUS, Color(1.0, 0.9, 0.5, 0.9), 0.7, 0.2)
		Sfx.play("boom", -4.0, 0.03)
		shake.emit(0.7)
	if state_time >= state_len:
		state = "free"


func start_dash() -> void:
	if state != "free" or dash_cd > 0.0:
		return
	state = "dash"
	state_time = 0.0
	state_len = 0.35
	dash_cd = 1.2
	invuln = maxf(invuln, 0.45)
	_play("gallop", 0.05, 1.8)
	Sfx.play("dash", -3.0)


func _state_dash(delta: float) -> void:
	state_time += delta
	speed = 26.0
	_move(_facing() * speed, delta)
	dust.emitting = true
	if state_time >= state_len:
		state = "free"


# ------------------------------------------------------------------ damage / life
func take_damage(amount: float, _from: Vector3) -> void:
	if invuln > 0.0 or state == "dead" or state == "victory" or anim_test or Game.demo:
		return
	hp = maxf(0.0, hp - amount)
	invuln = 0.55
	Game.player_hp_changed.emit(hp, max_hp)
	shake.emit(0.35)
	Sfx.play("hurt", 0.0)
	if randf() < 0.25:
		Game.say("player_hurt")
	if hp <= 0.0:
		state = "dead"
		dust.emitting = false
		if anim:
			anim.stop()
		var tw := create_tween()
		tw.tween_property(model, "rotation:z", deg_to_rad(80.0), 0.8)
		Game.player_died.emit()


func heal(amount: float) -> void:
	if state == "dead":
		return
	hp = minf(max_hp, hp + amount)
	Game.player_hp_changed.emit(hp, max_hp)


func _on_victory() -> void:
	if state == "dead":
		return
	state = "victory"
	speed = 0.0
	_play("victory", 0.4)


# ------------------------------------------------------------------ vfx
func _ring(radius: float, col: Color, dur: float, height: float) -> void:
	var m := MeshInstance3D.new()
	var t := TorusMesh.new()
	t.inner_radius = 0.92
	t.outer_radius = 1.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(col.r, col.g, col.b)
	t.material = mat
	m.mesh = t
	get_parent().add_child(m)
	m.global_position = global_position + Vector3(0, height, 0)
	m.scale = Vector3.ONE * 0.5
	var tw := m.create_tween()
	tw.set_parallel(true)
	tw.tween_property(m, "scale", Vector3(radius, 1.0, radius), dur)
	tw.tween_property(mat, "albedo_color:a", 0.0, dur)
	tw.chain().tween_callback(m.queue_free)


# ------------------------------------------------------------------ demo (screenshots/CI)
const DEMO_SEQ := [["idle", 2.0], ["walk", 2.0], ["trot", 2.0], ["gallop", 2.0],
	["slash", 1.2], ["rear", 2.0], ["victory", 2.0]]


func _demo(delta: float) -> void:
	demo_t += delta
	var total := 0.0
	for s in DEMO_SEQ:
		total += float(s[1])
	var t := fmod(demo_t, total)
	var cur := "idle"
	for s in DEMO_SEQ:
		if t < float(s[1]):
			cur = s[0]
			break
		t -= float(s[1])
	if cur == "slash" or cur == "rear":
		if anim and (anim.current_animation != String(anim_names.get(cur, "")) or not anim.is_playing()):
			anim.play(String(anim_names.get(cur, "")), 0.05)
		anim.speed_scale = 1.0
		speed = 0.0
	else:
		_play(cur, 0.1)
		speed = float(SPEEDS.get(cur, 0.0))
		yaw += 0.5 * delta if speed > 0.0 else 0.0
	_move(_facing() * speed, delta)
	dust.emitting = cur == "gallop"
