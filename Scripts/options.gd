extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
#	var node=find_child("mix_slider")
#	var vol=GlobalVars.get_vol("Master")	
#	node.value=vol
#	find_child("music_slider").value=GlobalVars.get_vol("Music")	
#	find_child("sfx_slider").value=GlobalVars.get_vol("SFX")	
	$MarginContainer/VBoxContainer/MarginContainer/volsliders/vcon_mix/mix_slider.value=GlobalVars.get_vol("Master")
	$MarginContainer/VBoxContainer/MarginContainer/volsliders/vcon_music/music_slider.value=GlobalVars.get_vol("Music")
	$MarginContainer/VBoxContainer/MarginContainer/volsliders/vcon_sfx/sfx_slider.value=GlobalVars.get_vol("SFX")
	$audio_music.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
