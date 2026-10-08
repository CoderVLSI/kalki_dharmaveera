extends Node3D
## Prototype scene: builds the world, player, camera, HUD and the rule-based spawner.

var world: WorldBuilder
var player: Player
var rig: CameraRig
var hud: Hud
var narayana: Node3D
var spawn_timer: float = 2.0
var rng := RandomNumberGenerator.new()
var seed_counter: int = 100


func _ready() -> void:
	Player.ensure_input()
	Game.reset()
	rng.seed = 7
	world = WorldBuilder.new()
	add_child(world)

	player = Player.new()
	add_child(player)
	rig = CameraRig.new()
	add_child(rig)
	rig.target = player
	rig.global_position = Vector3(0, 2, 8)
	player.shake.connect(rig.add_shake)

	hud = Hud.new()
	hud.player = player
	add_child(hud)

	_spawn_narayana()
	for i in 3:
		_spawn("raider", 26.0 + i * 4.0)
	if not Game.demo and not Game.skip_title:
		get_tree().paused = true
		var title := TitleScreen.new()
		add_child(title)
		await title.started
		get_tree().paused = false
	Game.skip_title = true
	await get_tree().create_timer(0.8).timeout
	Game.say("narayana_intro")
	await get_tree().create_timer(7.0).timeout
	_vanish_narayana()
	Game.say("shuka_start")
	Game.victory.connect(_appear_narayana)


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
	narayana.position = player.global_position + Vector3(0, 0, 0) + Vector3(-sin(player.yaw), 0, -cos(player.yaw)) * 12.0
	narayana.rotation.y = atan2(player.global_position.x - narayana.position.x, player.global_position.z - narayana.position.z)
	narayana.scale = Vector3.ONE * 0.01
	var tw := create_tween()
	tw.tween_property(narayana, "scale", Vector3.ONE * 1.9, 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# the host breaks: remaining enemies fall
	for e in get_tree().get_nodes_in_group("enemies"):
		e.take_damage(9999.0, player.global_position, 4.0, 0.0)


func _process(delta: float) -> void:
	if narayana and narayana.visible:
		narayana.position.y = 0.25 + sin(Time.get_ticks_msec() * 0.0015) * 0.15
	if Input.is_action_just_pressed("restart"):
		Game.reset()
		get_tree().reload_current_scene()
	if Game.finished or player.state == "dead":
		return
	_spawner(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not player.anim_test and player.state == "free":
			player.start_slash()


func _spawner(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	var rule: Dictionary = {}
	for r in Game.world_cfg["spawn_table"]:
		if Game.dharma >= float(r["from"]):
			rule = r
	spawn_timer = float(rule["interval"])
	if get_tree().get_nodes_in_group("enemies").size() >= int(rule["max_alive"]):
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
	_spawn(kind, rng.randf_range(32.0, 46.0))


func _spawn(kind: String, dist: float) -> void:
	var a := rng.randf() * TAU
	var pos := player.global_position + Vector3(cos(a), 0, sin(a)) * dist
	var flat := Vector2(pos.x, pos.z)
	if flat.length() > 140.0:
		flat = flat.normalized() * 140.0
		pos = Vector3(flat.x, 0, flat.y)
	var e := Enemy.new()
	seed_counter += 1
	e.setup(kind, pos, player, seed_counter)
	add_child(e)
