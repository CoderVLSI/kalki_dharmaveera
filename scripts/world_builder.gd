class_name WorldBuilder
extends Node3D
## Builds the arena and applies the world-state rule table:
## Dharma 0 (Kali Yuga: ash, red haze, dead trees) -> 100 (Satya Yuga: gold light, green, bloom).

const DEAD := {
	"sky_top": Color(0.17, 0.08, 0.08), "sky_horizon": Color(0.55, 0.27, 0.17),
	"ground": Color(0.50, 0.42, 0.34), "fog": Color(0.42, 0.24, 0.17), "fog_density": 0.011,
	"light": Color(1.0, 0.62, 0.46), "light_energy": 1.0, "ambient": 0.7,
	"crown": Color(0.20, 0.16, 0.14), "mountain": Color(0.28, 0.22, 0.22),
}
const ALIVE := {
	"sky_top": Color(0.28, 0.55, 0.95), "sky_horizon": Color(1.0, 0.90, 0.66),
	"ground": Color(0.50, 0.68, 0.30), "fog": Color(0.95, 0.88, 0.70), "fog_density": 0.003,
	"light": Color(1.0, 0.96, 0.82), "light_energy": 1.5, "ambient": 1.0,
	"crown": Color(0.30, 0.65, 0.25), "mountain": Color(0.80, 0.78, 0.74),
}

var env: Environment
var sky_mat: ProceduralSkyMaterial
var sun: DirectionalLight3D
var ground_mat: StandardMaterial3D
var mountain_mat: StandardMaterial3D
var tree_spots: Array = []   # [Vector3 position, yaw, scale, is_dead]
var tree_multis: Array = []  # [MultiMesh, Transform3D part_xf, is_dead]
var pillars: Dictionary = {}  # id -> Node3D
var level: float = 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = 1008  # seeded: reproducible world
	_build_environment()
	_build_ground()
	_build_trees()
	_build_mountains()
	_build_village()
	_build_pillars()
	Game.dharma_changed.connect(_on_dharma)
	apply(Game.dharma)


func _build_environment() -> void:
	sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sun_angle_max = 25.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -35, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)


func _build_ground() -> void:
	var body := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(800, 800)
	ground_mat = StandardMaterial3D.new()
	var noise := FastNoiseLite.new()
	noise.frequency = 0.02
	var tex := NoiseTexture2D.new()
	tex.noise = noise
	tex.seamless = true
	tex.width = 512
	tex.height = 512
	ground_mat.albedo_texture = tex
	ground_mat.uv1_scale = Vector3(60, 60, 1)
	ground_mat.roughness = 1.0
	plane.material = ground_mat
	body.mesh = plane
	add_child(body)


## Dead (ash) and living trees scattered on the same seeded spots; Dharma crossfades them by
## scale. MultiMesh keeps it cheap on phones.
func _build_trees() -> void:
	for i in 70:
		var a := rng.randf() * TAU
		var r := rng.randf_range(14.0, 120.0)
		tree_spots.append([Vector3(cos(a) * r, 0, sin(a) * r), rng.randf() * TAU, rng.randf_range(0.8, 1.5), i % 2 == 0])
	for dead in [true, false]:
		var model := "tree_dead" if dead else "tree_alive"
		for part in Props.parts(model):
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = part[0]
			mm.instance_count = tree_spots.size()
			var node := MultiMeshInstance3D.new()
			node.multimesh = mm
			node.custom_aabb = AABB(Vector3(-160, -2, -160), Vector3(320, 40, 320))
			add_child(node)
			tree_multis.append([mm, part[1], dead])


func _place_trees(dharma: float) -> void:
	var alive := smoothstep(10.0, 70.0, dharma)
	for tm in tree_multis:
		var mm: MultiMesh = tm[0]
		var dead: bool = tm[2]
		var f := (1.0 - alive) if dead else alive
		for i in tree_spots.size():
			var sp: Array = tree_spots[i]
			var sc: float = float(sp[2]) * maxf(f, 0.001)
			var basis := Basis(Vector3.UP, float(sp[1])).scaled(Vector3.ONE * sc)
			mm.set_instance_transform(i, Transform3D(basis, sp[0]) * (tm[1] as Transform3D))


func _build_mountains() -> void:
	mountain_mat = StandardMaterial3D.new()
	mountain_mat.roughness = 1.0
	for part in Props.parts("prop_mountain"):
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = part[0]
		mm.instance_count = 18
		for i in 18:
			var a := float(i) / 18.0 * TAU + rng.randf_range(-0.1, 0.1)
			var sc := rng.randf_range(0.9, 1.7)
			var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(sc * 1.4, sc, sc * 1.4))
			mm.set_instance_transform(i, Transform3D(basis, Vector3(cos(a) * 300.0, -3.0, sin(a) * 300.0)) * (part[1] as Transform3D))
		var node := MultiMeshInstance3D.new()
		node.multimesh = mm
		node.material_override = mountain_mat
		node.custom_aabb = AABB(Vector3(-400, -10, -400), Vector3(800, 220, 800))
		add_child(node)


## Shambhala: a small village with a shrine, drawn from real models.
func _build_village() -> void:
	var spots := [
		["prop_hut_b", Vector3(-30, 0, -34), 0.3], ["prop_hut_b", Vector3(-38, 0, -30), 1.2],
		["prop_hut_b", Vector3(-26, 0, -42), -0.5], ["prop_hut_b", Vector3(-40, 0, -40), 2.0],
		["prop_candi", Vector3(-48, 0, -50), 0.6], ["prop_temple_wall", Vector3(-33, 0, -52), 0.0],
		["prop_bell", Vector3(-42, 0, -44), 0.0], ["prop_lotus", Vector3(-36, 0, -36), 0.0],
		["prop_lotus", Vector3(-34, 0, -38), 1.0], ["prop_lotus", Vector3(-38, 0, -35), 2.0],
	]
	for sp in spots:
		var n := Props.spawn(sp[0])
		if n == null:
			continue
		n.position = sp[1]
		n.rotation.y = sp[2]
		add_child(n)


## The four legs of Dharma return as standing columns when each pillar is restored.
func _build_pillars() -> void:
	var ids: Array = []
	for p in Game.world_cfg.get("pillars", []):
		ids.append(p["id"])
	for i in ids.size():
		var n := Props.spawn("prop_pillar")
		if n == null:
			return
		var a := TAU * (float(i) + 0.5) / float(ids.size())
		n.position = Vector3(cos(a) * 17.0, 0, sin(a) * 17.0)
		n.scale = Vector3.ONE * 0.001
		n.visible = false
		add_child(n)
		pillars[ids[i]] = n
	Game.pillar_restored.connect(_raise_pillar)
	for id in Game.restored:
		_raise_pillar(id)


func _raise_pillar(id: String) -> void:
	var n: Node3D = pillars.get(id)
	if n == null:
		return
	n.visible = true
	create_tween().tween_property(n, "scale", Vector3.ONE * 1.6, 1.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_dharma(value: float) -> void:
	var tw := create_tween()
	tw.tween_method(apply, level, value / 100.0 * 100.0, 1.2)


func apply(dharma: float) -> void:
	level = dharma
	var t := smoothstep(0.0, 100.0, dharma)
	var lerp_c := func(k: String) -> Color: return (DEAD[k] as Color).lerp(ALIVE[k], t)
	sky_mat.sky_top_color = lerp_c.call("sky_top")
	sky_mat.sky_horizon_color = lerp_c.call("sky_horizon")
	sky_mat.ground_horizon_color = lerp_c.call("sky_horizon")
	sky_mat.ground_bottom_color = (lerp_c.call("sky_top") as Color).darkened(0.4)
	env.fog_light_color = lerp_c.call("fog")
	env.fog_density = lerpf(DEAD["fog_density"], ALIVE["fog_density"], t)
	env.ambient_light_energy = lerpf(DEAD["ambient"], ALIVE["ambient"], t)
	sun.light_color = lerp_c.call("light")
	sun.light_energy = lerpf(DEAD["light_energy"], ALIVE["light_energy"], t)
	ground_mat.albedo_color = lerp_c.call("ground")
	mountain_mat.albedo_color = lerp_c.call("mountain")
	_place_trees(dharma)
