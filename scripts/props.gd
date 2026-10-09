class_name Props
extends RefCounted
## Helpers for the Sketchfab models in assets/models (prepped by tools/blender/prep_prop.py:
## real-world height, base on y=0, footprint centred).

static func path(model: String) -> String:
	return "res://assets/models/%s.glb" % model


## A ready-to-add instance, or null if the file is missing.
static func spawn(model: String) -> Node3D:
	var p := path(model)
	if not ResourceLoader.exists(p):
		push_warning("missing model " + p)
		return null
	return (load(p) as PackedScene).instantiate()


## [[Mesh, Transform3D relative to the model root], ...] for MultiMesh scattering.
static func parts(model: String) -> Array:
	var out := []
	var root := spawn(model)
	if root == null:
		return out
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var xf := Transform3D.IDENTITY
		var n: Node = mi
		while n != null and n != root:
			xf = (n as Node3D).transform * xf
			n = n.get_parent()
		out.append([mi.mesh, xf])
	root.free()
	return out


## Character slots for hand-made models (e.g. Hyper3D Rodin exports). Drop a GLB named
## assets/models/char_<slot>.glb and it is used automatically, fitted to `height` metres with its
## feet on y=0 and centred, front toward +Z (glTF default). Slots: brahma, shiva, kalki_baby,
## kalki_child (4-5 yr), kalki_teen, kalki (adult). Returns null when the slot is empty so callers
## fall back to their stand-in. Only for static, unskinned meshes: measured from mesh AABBs.
static func character(slot: String, height: float) -> Node3D:
	var m := spawn("char_" + slot)
	if m == null:
		return null
	var holder := Node3D.new()
	holder.add_child(m)
	var lo := Vector3(1e9, 1e9, 1e9)
	var hi := Vector3(-1e9, -1e9, -1e9)
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var xf := Transform3D.IDENTITY
		var n: Node = mi
		while n != null and n != m:
			xf = (n as Node3D).transform * xf
			n = n.get_parent()
		var bb: AABB = xf * (mi as MeshInstance3D).get_aabb()
		lo = lo.min(bb.position)
		hi = hi.max(bb.end)
	if hi.y - lo.y < 0.0001:
		holder.free()
		return null
	var k := height / (hi.y - lo.y)
	m.scale = Vector3.ONE * k
	m.position = -Vector3((lo.x + hi.x) * 0.5, lo.y, (lo.z + hi.z) * 0.5) * k
	return holder
