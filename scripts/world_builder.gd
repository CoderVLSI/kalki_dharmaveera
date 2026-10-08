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
var crown_mat: StandardMaterial3D
var mountain_mat: StandardMaterial3D
var crowns: Array = []     # [MeshInstance3D, base_scale: float]
var level: float = 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = 1008  # seeded: reproducible world
	_build_environment()
	_build_ground()
	_build_trees()
	_build_mountains()
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


func _build_trees() -> void:
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.25, 0.17, 0.12)
	crown_mat = StandardMaterial3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.3
	trunk_mesh.height = 3.0
	trunk_mesh.material = trunk_mat
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.0
	crown_mesh.height = 2.0
	crown_mesh.material = crown_mat
	for i in 170:
		var a := rng.randf() * TAU
		var r := rng.randf_range(14.0, 150.0)
		var t := Node3D.new()
		t.position = Vector3(cos(a) * r, 0, sin(a) * r)
		var s := rng.randf_range(0.8, 1.7)
		t.scale = Vector3.ONE * s
		var trunk := MeshInstance3D.new()
		trunk.mesh = trunk_mesh
		trunk.position.y = 1.5
		t.add_child(trunk)
		var crown := MeshInstance3D.new()
		crown.mesh = crown_mesh
		crown.position.y = 3.6
		t.add_child(crown)
		add_child(t)
		crowns.append([crown, rng.randf_range(1.5, 2.4), rng.randf_range(-0.08, 0.08)])


func _build_mountains() -> void:
	mountain_mat = StandardMaterial3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 1.0
	cone.height = 1.0
	cone.material = mountain_mat
	for i in 18:
		var a := float(i) / 18.0 * TAU + rng.randf_range(-0.1, 0.1)
		var m := MeshInstance3D.new()
		m.mesh = cone
		var h := rng.randf_range(60.0, 130.0)
		var w := rng.randf_range(60.0, 110.0)
		m.scale = Vector3(w, h, w)
		m.position = Vector3(cos(a) * 300.0, h * 0.5 - 2.0, sin(a) * 300.0)
		add_child(m)


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
	crown_mat.albedo_color = lerp_c.call("crown")
	mountain_mat.albedo_color = lerp_c.call("mountain")
	for c in crowns:
		var mesh: MeshInstance3D = c[0]
		var base: float = c[1]
		# dead trees keep a sparse dark crown; living trees leaf out
		var s := lerpf(0.25, base, t)
		mesh.scale = Vector3(s, s * 0.8, s)
