extends Control


@export var resolutions = {
	"3840x2160": Vector2(3840,2160),
	"2560x1440": Vector2(2560,1440),
	"1920x1080": Vector2(1920,1080),
	"1366x768": Vector2(1366,768),
	"1280x720": Vector2(1280,720),
	"1440x900": Vector2(1440,900),
	"1600x900": Vector2(1600,900),
	"1024x600": Vector2(1024,600),
	"800x600": Vector2(800,600),
	"640x360": Vector2(640,360)
}

@onready var resolution_option_button = $PanelContainer/MenuOptions/ResolutionOption/OptionButton
@onready var master_slider = $PanelContainer/MenuOptions/VolumeSliders/Controls/MasterSlider
@onready var music_slider = $PanelContainer/MenuOptions/VolumeSliders/Controls/MusicSlider
@onready var effect_slider = $PanelContainer/MenuOptions/VolumeSliders/Controls/EffectsSlider
@onready var mute_checkbox = $PanelContainer/MenuOptions/MuteOption/MuteCheckBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save_dict = {}
	
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var json_object = JSON.new()
		var parse_err = json_object.parse(save_file.get_as_text())
		save_dict = json_object.get_data()
	else:
		# Give standard settings
		pass
	
	master_slider.value = save_dict["master_vol"]
	music_slider.value = save_dict["music_vol"]
	effect_slider.value = save_dict["effect_vol"]
	
	mute_checkbox.button_pressed = save_dict["muted"]
	
	for r in resolutions:
		resolution_option_button.add_item(r)
		
	resolution_option_button.select(save_dict["res"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_dict)
	
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


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
	var resolutions_index = resolutions.keys().find(window_size_string)
	resolution_option_button.selected = resolutions_index


func _on_option_button_item_selected(index: int) -> void:
	var key = resolution_option_button.get_item_text(index)
	get_window().set_size(resolutions[key])
	get_window().move_to_center()
