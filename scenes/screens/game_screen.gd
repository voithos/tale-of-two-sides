tool
class_name GameScreen
extends Screen

enum {
    DEMO_BASE,
    DEMO_DIEGO,
    DEMO_LEVI,
    DEMO_ZAVEN,
}

const PACKED_SCENES := {
    DEMO_BASE: preload("res://scenes/demos/demo_base.tscn"),
    DEMO_DIEGO: preload("res://scenes/demos/demo_diego.tscn"),
    DEMO_LEVI: preload("res://scenes/demos/demo_levi.tscn"),
    DEMO_ZAVEN: preload("res://scenes/demos/demo_zaven.tscn"),
}

var level_type := -1
var level


func _init().(ScreenController.GAME, PAUSE_MODE_STOP) -> void:
    pass


func _ready() -> void:
    pass


func set_level(level_type: int) -> void:
    if is_instance_valid(level) and \
            self.level_type == level_type:
        # We're already on this level.
        return
    
    if is_instance_valid(level):
        # Destroy any previous level.
        level.queue_free()
    
    self.level_type = level_type
    level = PACKED_SCENES[level_type].instance()
    add_child(level)


func on_screen_opened() -> void:
    screen.set_pause(false)
