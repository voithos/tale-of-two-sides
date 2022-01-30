class_name Main
extends Node2D
## -   This is the default entry-point for the application.
## -   During local development when you want to open directly to your
##     demo scene, use F6 to "Play Scene".


const START_LEVEL := LevelManifest.DEMO_BASE


func _ready() -> void:
    screen.set_level(START_LEVEL)
    screen.open_screen(ScreenController.MAIN_MENU)
