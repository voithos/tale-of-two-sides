tool
class_name PauseScreen
extends Screen


func _init().(ScreenController.PAUSE, PAUSE_MODE_PROCESS) -> void:
    pass


func _on_Button_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.set_pause(false)
