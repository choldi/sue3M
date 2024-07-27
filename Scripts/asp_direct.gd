extends AudioStreamPlayer
var offset = 0
var delay = 0

func _remove_self():
	queue_free()
func add_delay(d):
	delay=d
	
func play_sound(sound_stream):
	set_stream(sound_stream)
	finished.connect(_remove_self)
	print("before wait:" + str(delay))
	await get_tree().create_timer(delay).timeout
	print("after wait")
	play(offset)

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
