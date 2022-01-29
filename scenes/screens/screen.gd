tool
class_name Screen
extends PanelContainer


const DEFAULT_THEME := preload("res://default_theme.tres")
const DISPLAY_WINDOW_SIZE := Vector2(320, 180)

var type: int


func _init(type: int, pause_mode: int) -> void:
    self.type = type
    set_pause_mode(pause_mode)


func _ready() -> void:
    theme = DEFAULT_THEME
    rect_size = DISPLAY_WINDOW_SIZE
    _on_resized()
    get_viewport().connect(
            "size_changed",
            self,
            "_on_resized")


func _on_resized() -> void:
    print("Viewport size changed: %s" % str(get_viewport().size))
