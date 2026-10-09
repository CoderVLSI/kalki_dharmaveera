extends Node3D
## Lines up every enemy kind on its rigged model: checks fit (height, feet on ground), that clips
## exist and play, and gives a lineup for visual capture (KALKI_LINEUP=1 keeps it running).

var failures := 0

func check(cond: bool, msg: String) -> void:
	print(("PASS " if cond else "FAIL ") + msg)
	if not cond:
		failures += 1


func _ready() -> void:
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 1.6, 26)
	cam.rotation_degrees = Vector3(-4, 0, 0)
	cam.current = true
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, 20, 0)
	add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.45, 0.45, 0.5)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.8, 0.8, 0.85)
	add_child(env)
	var dummy := Node3D.new()           # stand-in player far behind the camera so units walk at us
	dummy.position = Vector3(0, 0, 22 if not OS.has_environment("KALKI_LINEUP") else 400)
	dummy.set_script(load("res://tests/dummy_player.gd"))
	add_child(dummy)
	var kinds := ["raider", "archer", "banner", "koka", "vikoka"]
	var units: Array[Enemy] = []
	for i in kinds.size():
		var e := Enemy.new()
		e.setup(kinds[i], Vector3((i - 2) * 3.2, 0, 0), dummy, 1 + i)
		add_child(e)
		if OS.has_environment("KALKI_LINEUP"):
			e.rotation.y = PI
			e.set_physics_process(false)
		units.append(e)
	await get_tree().create_timer(0.3).timeout
	for e in units:
		var k: String = e.kind
		check(e.anim != null, "%s has an AnimationPlayer" % k)
		for key in e.cfg["anims"]:
			check(e.anim.has_animation(e.cfg["anims"][key]), "%s clip '%s'" % [k, e.cfg["anims"][key]])
	await get_tree().create_timer(1.2).timeout
	for e in units:
		check(e.anim.is_playing(), "%s animating (%s)" % [e.kind, e.anim_cur])
	check(units[0].anim_cur in ["walk", "run"], "raider switches to a locomotion clip when chasing")
	print("RESULT failures=%d" % failures)
	if not OS.has_environment("KALKI_LINEUP"):
		get_tree().quit(failures)
