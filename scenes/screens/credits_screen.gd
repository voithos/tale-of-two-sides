tool
class_name CreditsScreen
extends Screen


func _init().(ScreenController.CREDITS, PAUSE_MODE_PROCESS) -> void:
    pass


func _ready() -> void:
    music.play(Music.PHASE_MENU)


func _on_DiegoLink_pressed() -> void:
    OS.shell_open("https://drgvdg.itch.io/")
    sfx.play(sfx.BUTTON_PRESS)


func _on_LeviLink_pressed() -> void:
    OS.shell_open("https://levi.dev")
    sfx.play(sfx.BUTTON_PRESS)


func _on_DaisyLink_pressed() -> void:
    OS.shell_open("https://ladychamomile.ink")
    sfx.play(sfx.BUTTON_PRESS)


func _on_ZavenLink_pressed() -> void:
    OS.shell_open("https://voithos.io")
    sfx.play(sfx.BUTTON_PRESS)
