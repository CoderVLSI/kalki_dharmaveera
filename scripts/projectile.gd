class_name Projectile
extends Node3D
## Archer bolt. Straight line, hits the player by distance check.

var vel: Vector3 = Vector3.ZERO
var damage: float = 8.0
var life: float = 4.0
var target: Node3D


func launch(from: Vector3, dir: Vector3, dmg: float, tgt: Node3D) -> void:
	global_position = from
	vel = dir * 22.0
	damage = dmg
	target = tgt
	var m := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 0.2
	s.height = 0.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.3, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.25, 0.05)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	s.material = mat
	m.mesh = s
	add_child(m)


func _physics_process(delta: float) -> void:
	global_position += vel * delta
	life -= delta
	if life <= 0.0 or global_position.y < 0.05:
		queue_free()
		return
	if target and global_position.distance_to(target.global_position + Vector3(0, 1.2, 0)) < 1.6:
		target.take_damage(damage, global_position)
		queue_free()
