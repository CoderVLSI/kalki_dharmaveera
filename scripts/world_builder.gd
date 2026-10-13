class_name WorldBuilder
extends Node3D
## Builds the arena and applies the world-state rule table:
## Dharma 0 (Kali Yuga: ash, red haze, dead trees) -> 100 (Satya Yuga: gold light, green, bloom).

const DEAD_DEFAULT := {
	"sky_top": Color(0.17, 0.08, 0.08), "sky_horizon": Color(0.55, 0.27, 0.17),
	"ground": Color(0.50, 0.42, 0.34), "fog": Color(0.42, 0.24, 0.17), "fog_density": 0.011,
	"light": Color(1.0, 0.62, 0.46), "light_energy": 1.0, "ambient": 0.7,
	"crown": Color(0.20, 0.16, 0.14), "mountain": Color(0.28, 0.22, 0.22),
}
const ALIVE_DEFAULT := {
	"sky_top": Color(0.28, 0.55, 0.95), "sky_horizon": Color(1.0, 0.90, 0.66),
	"ground": Color(0.50, 0.68, 0.30), "fog": Color(0.95, 0.88, 0.70), "fog_density": 0.003,
	"light": Color(1.0, 0.96, 0.82), "light_energy": 1.5, "ambient": 1.0,
	"crown": Color(0.30, 0.65, 0.25), "mountain": Color(0.80, 0.78, 0.74),
}

## Per-region looks (PDF section 8). Only the colours that differ from the defaults are listed.
const BIOMES := {
	"shambhala": {"dead": {"sky_top": Color(0.35, 0.28, 0.3), "sky_horizon": Color(0.85, 0.6, 0.4), "ground": Color(0.55, 0.5, 0.36), "fog": Color(0.7, 0.55, 0.4), "fog_density": 0.006},
		"alive": {"ground": Color(0.46, 0.66, 0.28)}},
	"mahendra": {"dead": {"sky_top": Color(0.3, 0.38, 0.5), "sky_horizon": Color(0.8, 0.75, 0.65), "ground": Color(0.42, 0.46, 0.38), "fog": Color(0.7, 0.72, 0.72), "fog_density": 0.012, "mountain": Color(0.42, 0.42, 0.45)},
		"alive": {"ground": Color(0.38, 0.58, 0.34), "mountain": Color(0.55, 0.56, 0.6)}},
	"shrine": {"dead": {"sky_top": Color(0.45, 0.3, 0.3), "sky_horizon": Color(1.0, 0.7, 0.35), "ground": Color(0.66, 0.55, 0.38), "fog": Color(0.9, 0.65, 0.4), "fog_density": 0.007},
		"alive": {"ground": Color(0.62, 0.62, 0.34)}},
	"court": {"dead": {"sky_top": Color(0.3, 0.45, 0.65), "sky_horizon": Color(0.95, 0.85, 0.7), "ground": Color(0.7, 0.62, 0.48), "fog": Color(0.85, 0.8, 0.7), "fog_density": 0.005},
		"alive": {"ground": Color(0.5, 0.7, 0.4)}},
	"simhala": {"dead": {"sky_top": Color(0.2, 0.5, 0.75), "sky_horizon": Color(0.9, 0.95, 0.9), "ground": Color(0.72, 0.68, 0.52), "fog": Color(0.8, 0.9, 0.9), "fog_density": 0.004},
		"alive": {"ground": Color(0.42, 0.72, 0.5)}},
	"vision": {"dead": {"sky_top": Color(0.55, 0.5, 0.75), "sky_horizon": Color(1.0, 0.95, 0.8), "ground": Color(0.85, 0.8, 0.7), "fog": Color(1.0, 0.95, 0.85), "fog_density": 0.018, "light_energy": 1.3},
		"alive": {"ground": Color(0.9, 0.85, 0.7), "fog_density": 0.012}},
	"himalaya": {"dead": {"sky_top": Color(0.3, 0.42, 0.65), "sky_horizon": Color(0.85, 0.9, 0.95), "ground": Color(0.86, 0.9, 0.95), "fog": Color(0.8, 0.86, 0.92), "fog_density": 0.011, "mountain": Color(0.9, 0.92, 0.97), "light": Color(0.9, 0.93, 1.0)},
		"alive": {"ground": Color(0.9, 0.94, 0.98), "mountain": Color(0.95, 0.96, 1.0)}},
	"kalapa": {"dead": {"sky_top": Color(0.3, 0.5, 0.6), "sky_horizon": Color(0.85, 0.82, 0.65), "ground": Color(0.5, 0.58, 0.34), "fog": Color(0.7, 0.75, 0.6), "fog_density": 0.007},
		"alive": {"ground": Color(0.4, 0.68, 0.3)}},
	"visasana": {"dead": {"sky_top": Color(0.06, 0.03, 0.05), "sky_horizon": Color(0.4, 0.1, 0.08), "ground": Color(0.22, 0.17, 0.16), "fog": Color(0.25, 0.08, 0.06), "fog_density": 0.02, "light": Color(1.0, 0.4, 0.3), "light_energy": 0.8, "mountain": Color(0.14, 0.1, 0.1)},
		"alive": {"ground": Color(0.45, 0.5, 0.3)}},
	"bhallata": {"dead": {"sky_top": Color(0.4, 0.3, 0.3), "sky_horizon": Color(0.95, 0.7, 0.4), "ground": Color(0.6, 0.5, 0.36), "fog": Color(0.8, 0.6, 0.4), "fog_density": 0.008},
		"alive": {"ground": Color(0.55, 0.65, 0.34)}},
	"kanchana": {"dead": {"sky_top": Color(0.1, 0.2, 0.15), "sky_horizon": Color(0.5, 0.7, 0.4), "ground": Color(0.3, 0.38, 0.26), "fog": Color(0.4, 0.6, 0.35), "fog_density": 0.028, "light": Color(0.7, 1.0, 0.6), "light_energy": 0.9},
		"alive": {"ground": Color(0.4, 0.62, 0.34), "fog_density": 0.006}},
	"restored": {"dead": {"ground": Color(0.5, 0.58, 0.34), "sky_top": Color(0.4, 0.55, 0.8), "sky_horizon": Color(1.0, 0.9, 0.7), "fog_density": 0.005},
		"alive": {}},
	"vaikuntha": {"dead": {"sky_top": Color(0.6, 0.65, 0.95), "sky_horizon": Color(1.0, 0.95, 0.8), "ground": Color(0.95, 0.9, 0.75), "fog": Color(1.0, 0.96, 0.85), "fog_density": 0.014, "light": Color(1.0, 0.95, 0.8), "light_energy": 1.6},
		"alive": {"ground": Color(0.95, 0.92, 0.8), "fog_density": 0.01}},
}

var config: Dictionary = {}     # biome, trees (bool), mountains (bool), village (bool), pillars (bool), props [...]
var dead: Dictionary = {}
var alive: Dictionary = {}
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
	dead = DEAD_DEFAULT.duplicate()
	alive = ALIVE_DEFAULT.duplicate()
	var b: Dictionary = BIOMES.get(str(config.get("biome", "")), {})
	for k in b.get("dead", {}):
		dead[k] = b["dead"][k]
	for k in b.get("alive", {}):
		alive[k] = b["alive"][k]
	# alive colours default to the biome's dead ones where the biome is deliberately constant
	for k in b.get("dead", {}):
		if not b.get("alive", {}).has(k) and k in ["sky_top", "sky_horizon", "fog"] and config.get("constant_sky", false):
			alive[k] = dead[k]
	_build_environment()
	_build_ground()
	if config.get("trees", true):
		_build_trees()
	if config.get("mountains", true):
		_build_mountains()
	if config.get("village", true):
		_build_village()
	if config.get("pillars", true):
		_build_pillars()
	_build_props(config.get("props", []))
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
	env.tonemap_white = 6.0
	env.glow_enabled = true            # soft bloom on golden light and highlights
	env.glow_intensity = 0.5
	env.glow_bloom = 0.04
	env.adjustment_enabled = true      # slightly richer colour and contrast
	env.adjustment_contrast = 1.07
	env.adjustment_saturation = 1.12
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
	# fine bump so the ground reads as earth, not a flat colour wash
	var bump := FastNoiseLite.new()
	bump.frequency = 0.09
	bump.fractal_octaves = 4
	var nt := NoiseTexture2D.new()
	nt.noise = bump
	nt.seamless = true
	nt.as_normal_map = true
	nt.bump_strength = 6.0
	nt.width = 512
	nt.height = 512
	ground_mat.normal_enabled = true
	ground_mat.normal_texture = nt
	ground_mat.normal_scale = 0.8
	ground_mat.uv2_scale = Vector3(1, 1, 1)
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
## Mission scenery from the `play.props` list: {"model", "pos":[x,z], "rot":deg, "scale"}.
func _build_props(list: Array) -> void:
	for p in list:
		var n := Props.spawn(str(p["model"]))
		if n == null:
			continue
		var pos: Array = p.get("pos", [0, 0])
		n.position = Vector3(float(pos[0]), 0.0, float(pos[1]))
		n.rotation.y = deg_to_rad(float(p.get("rot", 0.0)))
		n.scale = Vector3.ONE * float(p.get("scale", 1.0))
		add_child(n)


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
	var lerp_c := func(k: String) -> Color: return (dead[k] as Color).lerp(alive[k], t)
	sky_mat.sky_top_color = lerp_c.call("sky_top")
	sky_mat.sky_horizon_color = lerp_c.call("sky_horizon")
	sky_mat.ground_horizon_color = lerp_c.call("sky_horizon")
	sky_mat.ground_bottom_color = (lerp_c.call("sky_top") as Color).darkened(0.4)
	env.fog_light_color = lerp_c.call("fog")
	env.fog_density = lerpf(dead["fog_density"], alive["fog_density"], t)
	env.ambient_light_energy = lerpf(dead["ambient"], alive["ambient"], t)
	sun.light_color = lerp_c.call("light")
	sun.light_energy = lerpf(dead["light_energy"], alive["light_energy"], t)
	ground_mat.albedo_color = lerp_c.call("ground")
	if mountain_mat:
		mountain_mat.albedo_color = lerp_c.call("mountain")
	_place_trees(dharma)
