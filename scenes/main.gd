class_name Main
extends Node2D
## -   This is the default entry-point for the application.
## -   During local development when you want to open directly to your
##     demo scene, use F6 to "Play Scene".


func _ready() -> void:
    screen.set_level(GameScreen.DEMO_BASE)
    screen.open_screen(ScreenController.MAIN_MENU)
