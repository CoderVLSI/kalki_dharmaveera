class_name Companion
extends Node3D
## Shuka the parrot, Kalki's companion (Kalki Purana I.3, gift of Mahadeva). Stand-in model:
## a macaw recoloured to the green of the Indian parrot by a hue-shift shader, until the
## user's own model (assets/models/char_shuka.glb) arrives. Hovers beside and behind Kalki.

const SHADER := """
shader_type spatial;
uniform sampler2D tex : source_color;
vec3 rgb2hsv(vec3 c){vec4 K=vec4(0.,-1./3.,2./3.,-1.);vec4 p=mix(vec4(c.bg,K.wz),vec4(c.gb,K.xy),step(c.b,c.g));vec4 q=mix(vec4(p.xyw,c.r),vec4(c.r,p.yzx),step(p.x,c.r));float d=q.x-min(q.w,q.y);float e=1.e-10;return vec3(abs(q.z+(q.w-q.y)/(6.*d+e)),d/(q.x+e),q.x);}
vec3 hsv2rgb(vec3 c){vec4 K=vec4(1.,2./3.,1./3.,3.);vec3 p=abs(fract(c.xxx+K.xyz)*6.-K.www);return c.z*mix(K.xxx,clamp(p-K.xxx,0.,1.),c.y);}
void fragment(){
	vec4 t=texture(tex,UV);
	vec3 h=rgb2hsv(t.rgb);
	if(h.x>0.45&&h.x<0.75){h.x=0.30;}            // blues -> parrot green
	else if(h.x>0.08&&h.x<0.2){h.x=0.17;h.y*=0.9;} // gold -> yellow-green
	ALBEDO=hsv2rgb(h);
	ROUGHNESS=0.7;
}
"""

var target: Node3D
var model: Node3D
var anim: AnimationPlayer
var t: float = 0.0
var height: float = 0.9
var turn_deg: float = 180.0


func _ready() -> void:
	var custom := Props.character("shuka", height)   # the user's hand-made parrot wins when present
	if custom:
		model = custom
		add_child(model)
		return
	var holder := Props.spawn("comp_shuka")
	if holder == null:
		return
	model = Node3D.new()
	add_child(model)
	model.add_child(holder)
	holder.scale = Vector3.ONE * height
	holder.rotation.y = deg_to_rad(turn_deg)
	var sh := Shader.new()
	sh.code = SHADER
	for mi in holder.find_children("*", "MeshInstance3D", true, false):
		var src := (mi as MeshInstance3D).mesh.surface_get_material(0)
		var mat := ShaderMaterial.new()
		mat.shader = sh
		if src is BaseMaterial3D and src.albedo_texture:
			mat.set_shader_parameter("tex", src.albedo_texture)
		(mi as MeshInstance3D).material_override = mat
	var ap := holder.find_children("*", "AnimationPlayer", true, false)
	if ap.size() > 0:
		anim = ap[0]
		var n: String = anim.get_animation_list()[0]
		anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
		anim.play(n)


func _process(delta: float) -> void:
	if target == null or model == null:
		return
	t += delta
	var yaw: float = target.get("yaw") if target.get("yaw") != null else target.rotation.y
	var back := Basis(Vector3.UP, yaw)
	var want: Vector3 = target.global_position + back * Vector3(-1.4, 2.4 + sin(t * 2.2) * 0.12, 0.6)
	global_position = global_position.lerp(want, 1.0 - exp(-4.0 * delta))
	rotation.y = lerp_angle(rotation.y, yaw, 1.0 - exp(-5.0 * delta))
	rotation.z = sin(t * 2.2) * 0.08
