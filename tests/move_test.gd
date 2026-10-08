extends Node
## Drives the real main scene with simulated input and prints how the player moves
## relative to the camera. Camera forward is "up the screen".

func _ready() -> void:
	Game.skip_title = true
	var main: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	for action in ["move_forward", "move_right", "move_back", "move_left"]:
		var p: Player = main.player
		var cam := get_viewport().get_camera_3d()
		p.global_position = Vector3.ZERO
		p.yaw = 0.0
		p.speed = 0.0
		Input.action_press(action)
		await get_tree().create_timer(1.2).timeout
		Input.action_release(action)
		var cam_fwd := -cam.global_transform.basis.z
		cam_fwd.y = 0
		cam_fwd = cam_fwd.normalized()
		var cam_right := cam.global_transform.basis.x
		cam_right.y = 0
		cam_right = cam_right.normalized()
		var moved := p.global_position
		var face := -p.global_transform.basis.z
		print("%s: moved fwd=%.1f right=%.1f (cam-relative) | facing dot cam_fwd=%.2f dot cam_right=%.2f | cam z-offset from player=%.1f" % [
			action, moved.dot(cam_fwd), moved.dot(cam_right), face.dot(cam_fwd), face.dot(cam_right),
			cam.global_position.z - p.global_position.z])
		await get_tree().create_timer(0.5).timeout
	get_tree().quit()
