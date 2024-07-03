extends Node2D

@export var color:String
@export var matched=false

func move(pos):
	var tween = create_tween()
	tween.tween_property(self, "position", pos, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.play() 
# Called when the node enters the scene tree for the first time.

func dim():
	var sp=get_node("sprite")
	sp.self_modulate=Color(1,1,1,.5)

func match():
	self.dim()
	self.matched=true

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
