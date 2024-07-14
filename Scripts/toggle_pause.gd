extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grid_toggle_pause(paused):
	if paused:
		self.texture_normal=load("res://Assets/Buttons/play_btn.png")
		get_parent().get_node("restart").disabled=false
	else:
		self.texture_normal=load("res://Assets/Buttons/pause_btn.png")
		get_parent().get_node("restart").disabled=true
