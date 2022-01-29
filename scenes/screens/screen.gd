tool
class_name Screen
extends PanelContainer


const DEFAULT_THEME := preload("res://default_theme.tres")


func _ready() -> void:
    theme = DEFAULT_THEME
