tool
class_name EndStoryScreen
extends Screen

onready var sprite = $CenterContainer/VBoxContainer/HBoxContainer/Sprite

var tween = Tween.new()

func _init().(ScreenController.END_STORY, PAUSE_MODE_PROCESS) -> void:
    pass

const TRANSITION_TIME = 1
const HOLD_TIME = 2

func _ready() -> void:
    music.play(Music.PHASE_MENU)
    
    sprite.modulate.a = 0
    
    add_child(tween)
    
    tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_completed")
    
    yield(get_tree().create_timer(HOLD_TIME), "timeout")

    tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, "tween_completed")
    
    yield(get_tree().create_timer(0.5), "timeout")


    # Show credits!
    screen.open_screen(ScreenController.CREDITS)
