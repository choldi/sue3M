extends Marker2D

var display:String
var color:Color
var pos:Vector2
var tween:Tween
var distance:int=50
var duration:float=0.25
var dest_node
# Called when the node enters the scene tree for the first time.
func _ready():
	print("on ready floating text")
	
	tween = create_tween()
	
	pass # Replace with function body.


func move_up(pos:Vector2, col:Color,lbl:String):
	$lblEtiq.add_theme_color_override("font_color",col)
	$lblEtiq.text=lbl
#	pos.x=pos.x+GlobalVars.offset
	self.pos=pos
	tween.tween_property($lblEtiq, "position", pos, 0)	
	tween.tween_property($lblEtiq, "position", pos, duration)
	tween.tween_property($lblEtiq, "position:y", pos.y - distance, duration)	
	tween.tween_property($lblEtiq, "modulate:a", 0.0, duration)
	tween.tween_callback($lblEtiq.queue_free)
	tween.play()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
