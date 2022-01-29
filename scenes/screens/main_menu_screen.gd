tool
class_name MainMenuScreen
extends Screen


const DISPLAY_WINDOW_SIZE := Vector2(320, 180)


func _ready() -> void:
    rect_size = DISPLAY_WINDOW_SIZE
    _on_resized()
    get_viewport().connect(
            "size_changed",
            self,
            "_on_resized")


func _on_resized() -> void:
    print("Viewport size changed: %s" % str(get_viewport().size))


func _on_Button_pressed() -> void:
    # TODO: Start level.
    pass
    sfx.play(sfx.PICKUP_CRYSTAL)
