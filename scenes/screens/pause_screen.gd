tool
class_name PauseScreen
extends Screen


func _init().(ScreenController.PAUSE, PAUSE_MODE_PROCESS) -> void:
    pass


func _on_CloseButton_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    
    # Give the sfx some time to run.
    var timer = Timer.new()
    add_child(timer)
    timer.connect("timeout", screen, "close_app")
    timer.wait_time = 0.3
    timer.one_shot = true
    timer.start()


func _on_RestartButton_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.set_pause(false)
    screen.game_screen.level_logic.reset()


func _on_UnpauseButton_pressed() -> void:
    sfx.play(sfx.BUTTON_PRESS)
    screen.set_pause(false)
