extends Control

@onready var resolution_option_button: OptionButton = $PanelContainer/MenuOptions/ResolutionOption/OptionButton
@onready var master_slider = $PanelContainer/MenuOptions/VolumeSliders/Controls/MasterSlider
@onready var music_slider = $PanelContainer/MenuOptions/VolumeSliders/Controls/MusicSlider
@onready var effect_slider = $PanelContainer/MenuOptions/VolumeSliders/Controls/EffectsSlider
@onready var mute_checkbox = $PanelContainer/MenuOptions/MuteOption/MuteCheckBox


func _ready() -> void:
	for r in Settings.resolutions.keys():
			resolution_option_button.add_item(r)
	
	var settings = Settings.save_dict
	
	if settings != {}:
		master_slider.value = settings["master_vol"]
		music_slider.value = settings["music_vol"]
		effect_slider.value = settings["effect_vol"]
		
		mute_checkbox.button_pressed = settings["muted"]
		
		resolution_option_button.select(settings["res"])
	else:
		# Select last one if no preset (640 x 360)
		resolution_option_button.select(len(Settings.resolutions) - 1)

func _on_exit_button_pressed() -> void:
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	var save_dict = {
		"res": resolution_option_button.get_selected_id(),
		"master_vol": master_slider.value,
		"music_vol": music_slider.value,
		"effect_vol": effect_slider.value,
		"muted": mute_checkbox.button_pressed
	}
	
	var save_file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)

	var json_string = JSON.stringify(save_dict)
	

	save_file.store_line(json_string)
	
	Global._change_view(Global.MAIN_MENU_SCENE)
	get_parent().remove_child(self)

func _on_master_slider_value_changed(value: float) -> void:
	var master_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_index, linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	var music_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_index, linear_to_db(value))


func _on_effects_slider_value_changed(value: float) -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))
	
	
func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)


func update_button_values():
	var window_size_string = str(get_window().size.x, "x", get_window().size.x, "y")
	var resolutions_index = Settings.resolutions.keys().find(window_size_string)
	resolution_option_button.selected = resolutions_index


func _on_option_button_item_selected(index: int) -> void:
	var key = resolution_option_button.get_item_text(index)
	get_window().set_size(Settings.resolutions[key])
	get_window().move_to_center()
