extends SceneTree
## Prints the world-space direction the horse's head points (tail -> head) for yaw = 0.
## Player forward is -Z, so a correct model prints approximately (0, *, -1).

func _init() -> void:
	var scene: PackedScene = load("res://assets/models/kalki_devadatta_rigged.glb")
	var holder := Node3D.new()
	root.add_child(holder)
	var model: Node3D = scene.instantiate()
	holder.add_child(model)
	await process_frame
	var skel: Skeleton3D = model.find_children("*", "Skeleton3D", true, false)[0]
	var head := skel.get_bone_global_rest(skel.find_bone("head")).origin
	var tail := skel.get_bone_global_rest(skel.find_bone("tail_3")).origin
	var gl := skel.global_transform
	var dir := (gl * head - gl * tail).normalized()
	print("MODEL raw  head-from-tail dir (no extra rotation): ", dir)
	holder.rotation.y = PI
	var d2 := ((holder.global_transform * (gl * head)) - (holder.global_transform * (gl * tail))).normalized()
	print("MODEL after PI rotation: ", d2)
	var anim: AnimationPlayer = model.find_children("*", "AnimationPlayer", true, false)[0]
	print("ANIMS: ", anim.get_animation_list())
	quit()
