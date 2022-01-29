tool
class_name GameScreen
extends Screen


const DEMO_BASE := preload("res://scenes/demos/demo_base.tscn")
const DEMO_DIEGO := preload("res://scenes/demos/demo_diego.tscn")
const DEMO_LEVI := preload("res://scenes/demos/demo_levi.tscn")
const DEMO_ZAVEN := preload("res://scenes/demos/demo_zaven.tscn")


var current_level


func _init().(ScreenController.GAME, PAUSE_MODE_STOP) -> void:
    pass


# TODO: Add level-switching.


func _ready() -> void:
    pass


func on_screen_opened() -> void:
    screen.set_pause(false)
    
    # TODO: Choose the correct level to render.
    if !is_instance_valid(current_level):
        current_level = DEMO_BASE.instance()
        $ViewportContainer/Viewport.add_child(current_level)
