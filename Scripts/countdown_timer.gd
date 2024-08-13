extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_ui_stop_game():
	self.stop()


func _on_grid_toggle_pause(paused):
	if paused:
		self.stop()
	else:
		self.start()


func _on_grid_reset_timer():
	self.start()



func _on_grid_start_timer():
	self.start()


func _on_grid_pause_timer_collapse(pause):
	if pause:
		self.stop()
	else:
		self.start()
	pass # Replace with function body.
