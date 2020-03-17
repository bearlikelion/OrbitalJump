extends Label

    
func _process(delta):
    text = "fps: "
    text += str(Engine.get_frames_per_second())    
