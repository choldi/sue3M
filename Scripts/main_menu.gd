extends Node2D

@onready var game = preload("res://scenes/game.tscn")
@onready var options = preload("res://scenes/options.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$audio_music.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_btn_start_pressed():
	var ins_main=game.instantiate()
	var parent=get_parent()
	parent.remove_child(self)
	parent.add_child(ins_main)

func _on_btn_options_pressed():
	GlobalVars.last_scene=self
	var ins_option=options.instantiate()
	var parent=get_parent()
	parent.remove_child(self)
	parent.add_child(ins_option)
		


func _on_btn_exit_pressed():
	get_tree().quit()
	pass # Replace with function body.
