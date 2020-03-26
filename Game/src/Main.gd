extends Node2D

var Circle = preload("res://src/Objects/Circle.tscn")
var Player = preload("res://src/Objects/Player.tscn")

var player
var score = 0 setget set_score
var level = 0
onready var starting_score_per_level = Settings.circles_per_level

func _ready():
    $HUD.hide()
    Settings.circles_per_level = starting_score_per_level
        

func new_game():
    level = 1
    self.score = -1
    $Camera2D.position = $StartPosition.position    

    if Settings.enable_music:
        $Music.play()    

    player = Player.instance()
    player.position = $StartPosition.position
    add_child(player)
    player.connect("captured", self, "_on_Player_captured")
    player.connect("died", self, "_on_Player_died")
    
    Settings.themes.resize(0)
    change_theme()

    spawn_circle($StartPosition.position)

    $HUD.show()
    $HUD.show_message("Go!")


func change_theme():        
    Settings.themes.pop_front()
    if Settings.themes.size() == 0:             
        Settings.themes = Settings.color_schemes.values()        
                
    Settings.theme = Settings.themes[0]            
    player.change_theme()        
    

func set_score(value):
    score = value
    $HUD.update_score(score)
    if score > 0 and score % Settings.circles_per_level == 0:
        level += 1
        Settings.circles_per_level = int(round(Settings.circles_per_level * 1.5))
        print("Cirlces per: " + str(Settings.circles_per_level))
        
        change_theme()
        $HUD.show_message("Level %s" % str(level))
        

func spawn_circle(position=null):
    var cirlce = Circle.instance()
    # TODO: Better random range
    if !position:
        var x = rand_range(-200, 200)
        var y = rand_range(-600, -400)
        position = player.target.position + Vector2(x, y)
    add_child(cirlce)
    cirlce.init(position)


func _on_Player_captured(object):
    $Camera2D.position = object.position
    call_deferred("spawn_circle")
    $HUD.update_score(score)
    object.capture(player)
    self.score += 1


func _on_Player_died():
    get_tree().call_group("circles", "implode")

    if Settings.enable_music:
        $Music.stop()

    $HUD.hide()
    $Screens.game_over(score, level)
    $Camera2D.position = $StartPosition.position
