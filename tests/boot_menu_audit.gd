extends Node

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _contains_pad_accept() -> bool:
	for event in InputMap.action_get_events(&"ui_accept"):
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
			return true
	return false


func _collect_label_text(node: Node) -> String:
	var text := ""
	if node is Label:
		text += node.text + "\n"
	for child in node.get_children():
		text += _collect_label_text(child)
	return text


func _capture_view(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var directory := ProjectSettings.globalize_path("user://visual-audit")
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		_expect(false, "Could not create the menu visual-audit directory")
		return
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	error = image.save_png(directory.path_join(name))
	_expect(error == OK, "Could not save menu screenshot: " + name)


func _run() -> void:
	var hud := HUD.new()
	add_child(hud)
	await get_tree().process_frame
	await _capture_view("boot-menu.png")

	var menu := hud.get("_boot_menu") as Control
	var controls := hud.get("_boot_controls") as Control
	var boot_root := hud.get("_boot") as Control
	var background: TextureRect
	var title: RichTextLabel
	if is_instance_valid(boot_root):
		background = boot_root.find_child("MenuBackground", true, false) as TextureRect
	if is_instance_valid(menu):
		title = menu.find_child("GraffitiTitle", true, false) as RichTextLabel
	_expect(is_instance_valid(menu), "The initial menu view was not created")
	_expect(is_instance_valid(controls), "The controls view was not created")
	_expect(background != null and background.texture != null,
		"The initial menu has no city background")
	_expect(title != null and title.get_parsed_text() == "MARYLAND CITY",
		"The initial menu title is not Maryland City")
	_expect(_contains_pad_accept(), "Controller confirm is not mapped to ui_accept")
	var music := AudioFX.get("_menu_music_player") as AudioStreamPlayer
	var pad := AudioFX.get("_menu_pad_player") as AudioStreamPlayer
	var music_stream: AudioStreamWAV
	if music != null:
		music_stream = music.stream as AudioStreamWAV
	_expect(music != null and music.playing and music_stream != null
		and music_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD,
		"Looping menu music did not start")
	_expect(pad != null and pad.playing, "Menu ambience did not start")
	AudioFX.set_muted(true)
	_expect(music != null and music.stream_paused and pad != null and pad.stream_paused,
		"Menu audio did not respect mute")
	AudioFX.set_muted(false)
	_expect(music != null and not music.stream_paused and pad != null and not pad.stream_paused,
		"Menu audio did not resume after unmuting")
	if not is_instance_valid(menu) or not is_instance_valid(controls):
		_finish()
		return

	hud.call("_open_boot_controls")
	await get_tree().process_frame
	await _capture_view("boot-controls.png")
	_expect(controls.visible and not menu.visible,
		"The Controls button did not switch to the controls view")
	var help := _collect_label_text(controls)
	_expect(help.contains("Left stick") and help.contains("W")
		and help.contains("Alt fire") and help.contains("R3"),
		"The controls view is missing keyboard or controller bindings")
	var focused := get_viewport().gui_get_focus_owner()
	_expect(focused is Button, "The controls view has no gamepad/keyboard focus target")

	hud.call("_open_boot_controls")
	await get_tree().process_frame
	var cancel := InputEventJoypadButton.new()
	cancel.button_index = JOY_BUTTON_B
	cancel.pressed = true
	hud.call("_unhandled_input", cancel)
	await get_tree().process_frame
	_expect(menu.visible and not controls.visible,
		"Controller Back did not return to the initial menu")

	hud.call("_open_boot_controls")
	await get_tree().process_frame
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	hud.call("_unhandled_input", escape)
	_expect(menu.visible and not controls.visible,
		"Keyboard Escape did not return to the initial menu")
	hud.enter_game()
	_expect(music != null and not music.playing, "Menu music continued into gameplay")
	hud.queue_free()
	await get_tree().process_frame
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("BOOT_MENU_AUDIT_OK")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)
