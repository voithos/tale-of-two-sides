tool
class_name MainMenuScreen
extends Screen


func _init().(ScreenController.MAIN_MENU, PAUSE_MODE_PROCESS) -> void:
    pass


func _on_Button_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.set_level(levels.START_LEVEL)
    screen.open_screen(ScreenController.GAME)


func _input(event: InputEvent) -> void:
    if event is InputEventKey and \
            event.is_pressed() and \
            (event.scancode == KEY_ENTER or \
            event.scancode == KEY_SPACE):
        _on_Button_pressed()
