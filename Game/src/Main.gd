extends Node2D

var Circle = preload("res://src/Objects/Circle.tscn")
var Jumper = preload("res://src/Objects/Player.tscn")

var player
var score = 0 setget set_score
var level = 0
onready var starting_score_per_level = Settings.circles_per_level

func _ready():
    randomize()
    $HUD.hide()


func new_game():
    if Settings.enable_music:
        $Music.play()

    for circle in get_tree().get_nodes_in_group("circle"):
        circle.queue_free()

    $Camera2D.position = $StartPosition.position

    level = 1
    self.score = -1
    Settings.circles_per_level = starting_score_per_level

    player = Jumper.instance()
    player.position = $StartPosition.position
    add_child(player)
    player.connect("captured", self, "_on_Jumper_captured")
    player.connect("died", self, "_on_Jumper_died")

    spawn_circle($StartPosition.position)

    $HUD.show()
    $HUD.show_message("Go!")


func spawn_circle(_position=null):
    var c = Circle.instance()
    # TODO: Better random range
    if !_position:
        var x = rand_range(-200, 200)
        var y = rand_range(-600, -400)
        _position = player.target.position + Vector2(x, y)
    add_child(c)
    c.init(_position)


func _on_Jumper_captured(object):
    $Camera2D.position = object.position
    call_deferred("spawn_circle")
    $HUD.update_score(score)
    object.capture(player)
    self.score += 1


func set_score(value):
    score = value
    $HUD.update_score(score)
    if score > 0 and score % Settings.circles_per_level == 0:
        level += 1
        Settings.circles_per_level = int(round(Settings.circles_per_level * 1.5))
        print("Cirlces per: " + str(Settings.circles_per_level))
        $HUD.show_message("Level %s" % str(level))


func _on_Jumper_died():
    get_tree().call_group("circles", "implode")

    if Settings.enable_music:
        $Music.stop()

    $HUD.hide()
    $Screens.game_over(score)
    $Camera2D.position = $StartPosition.position
