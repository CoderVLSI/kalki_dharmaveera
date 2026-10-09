extends Node3D
## Visual helper: on-foot Kalki with the sword in hand, cycling idle / run / slash (use with --write-movie).
func _ready() -> void:
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(2.4, 1.3, 3.4)
	cam.current = true
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, 30, 0)
	add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.4, 0.42, 0.5)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.8, 0.8, 0.85)
	add_child(env)
	var k := Props.character("kalki", 1.8)
	add_child(k)
	cam.look_at(Vector3(0, 1.0, 0))
	var sw := Props.arm_with_sword(k)
	print("SWORD attached: ", sw != null)
	var ap: AnimationPlayer = k.find_children("*", "AnimationPlayer", true, false)[0]
	print("ANIMS ", ap.get_animation_list())
	for n in ["idle", "run", "walk"]:
		ap.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	var seq := ["idle", "slash", "run", "slash"]
	var i := 0
	while true:
		ap.play(seq[i % seq.size()])
		await get_tree().create_timer(1.0).timeout
		i += 1
