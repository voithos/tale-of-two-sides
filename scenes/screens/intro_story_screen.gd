tool
class_name IntroStoryScreen
extends Screen

onready var sprite = $CenterContainer/VBoxContainer/HBoxContainer/Sprite
onready var sprite2 = $CenterContainer/VBoxContainer/HBoxContainer/Sprite2

var tween = Tween.new()

func _init().(ScreenController.INTRO_STORY, PAUSE_MODE_PROCESS) -> void:
    pass

const TRANSITION_TIME = 1
const HOLD_TIME = 2

func _ready() -> void:
    music.play(Music.PHASE_MENU)
    
    sprite.modulate.a = 0
    sprite2.modulate.a = 0
    
    add_child(tween)
    
    tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_completed")
    
    yield(get_tree().create_timer(HOLD_TIME), "timeout")

    tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_completed")
    
    tween.interpolate_property(sprite2, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_completed")
    
    yield(get_tree().create_timer(HOLD_TIME), "timeout")

    tween.interpolate_property(sprite2, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_completed")
    
    yield(get_tree().create_timer(0.5), "timeout")


    # Start the game!
    screen.set_level(levels.START_LEVEL)
    screen.open_screen(ScreenController.GAME)
