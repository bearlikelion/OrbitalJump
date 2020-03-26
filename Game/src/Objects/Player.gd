extends Area2D

export var jump_speed = 1000
export var trail_length = 25

onready var trail = $Trail/Points

signal captured
signal died

var velocity = Vector2(250, 0)  # start value for testing
var target = null  # if we're on a circle

func _ready():
    $Sprite.material.set_shader_param("color", Settings.theme['player_body'])
    $Trail/Points.default_color = Settings.theme['player_trail']


func _unhandled_input(event):
    if target and event is InputEventScreenTouch and event.pressed:
        jump()
        
        
func jump():
    target.implode()
    target = null	
    velocity = transform.x * jump_speed
    
    if Settings.enable_sound:
        $Jump.play()

func _on_Jumper_area_entered(area):
    target = area	
    trail.clear_points()
    velocity = Vector2.ZERO        
    target.get_node("Pivot").rotation = (position - target.position).angle()
    emit_signal("captured", area)
    
    if Settings.enable_sound:
        $Capture.play()
        

func _physics_process(delta):
    if target:
        transform = target.orbit_position.global_transform        
    else:
        position += velocity * delta
        if trail.points.size() > trail_length:
            trail.remove_point(0)		
        trail.add_point(position)

func die():
    print("Player died")
    target = null
    emit_signal("died")
    queue_free()


func _on_VisibilityNotifier2D_screen_exited():
    if !target:
        die()
