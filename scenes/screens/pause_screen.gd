tool
class_name PauseScreen
extends Screen


func _init().(ScreenController.PAUSE, PAUSE_MODE_PROCESS) -> void:
    pass


func _on_RestartButton_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.set_pause(false)
    screen.game_screen.level_logic.reset()


func _on_UnpauseButton_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.set_pause(false)
