tool
class_name MainMenuScreen
extends Screen


func _init().(screen.MAIN_MENU, PAUSE_MODE_PROCESS) -> void:
    pass


func _on_Button_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.open_screen(screen.GAME)
