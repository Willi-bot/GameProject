extends Control


var resolutions = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/MenuOptions/VolumeSliders/Controls/MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$PanelContainer/MenuOptions/VolumeSliders/Controls/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	$PanelContainer/MenuOptions/VolumeSliders/Controls/EffectsSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
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


func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
