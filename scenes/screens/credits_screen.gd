tool
class_name CreditsScreen
extends Screen


func _init().(screen.CREDITS, PAUSE_MODE_PROCESS) -> void:
    pass


func _on_DiegoLink_pressed() -> void:
    # TODO
    OS.shell_open("https://github.com/voithos/global-game-jam-2022")
    sfx.play(sfx.BUTTON_PRESS)


func _on_LeviLink_pressed() -> void:
    OS.shell_open("https://levi.dev")
    sfx.play(sfx.BUTTON_PRESS)


func _on_DaisyLink_pressed() -> void:
    # TODO
    OS.shell_open("https://github.com/voithos/global-game-jam-2022")
    sfx.play(sfx.BUTTON_PRESS)


func _on_ZavenLink_pressed() -> void:
    OS.shell_open("https://voithos.io")
    sfx.play(sfx.BUTTON_PRESS)
