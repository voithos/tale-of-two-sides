class_name ScreenController
extends Node


enum {
    CREDITS,
    GAME,
    MAIN_MENU,
    PAUSE,
}

var packed_scenes := {
    CREDITS: load("res://scenes/screens/credits_screen.tscn"),
    GAME: load("res://scenes/screens/game_screen.tscn"),
    MAIN_MENU: load("res://scenes/screens/main_menu_screen.tscn"),
    PAUSE: load("res://scenes/screens/pause_screen.tscn"),
}

var is_paused := false

var screen_container: CanvasLayer
var game_screen
var current_screen


func _ready():
    set_pause_mode(PAUSE_MODE_PROCESS) # Never pause this node.
    if not OS.is_debug_build():
        OS.set_window_fullscreen(true)
    
    screen_container = CanvasLayer.new()
    add_child(screen_container)
    
    game_screen = packed_scenes[GAME].instance()
    add_child(game_screen)


func _input(event):
    if event is InputEventKey and event.is_pressed():
        if event.scancode == KEY_ESCAPE and not OS.has_feature("HTML5"):
            # Quitting doesn't make sense for web.
            get_tree().quit()
        if event.scancode == KEY_F11:
            OS.window_fullscreen = not OS.window_fullscreen

        if OS.is_debug_build():
            if event.scancode == KEY_P:
                set_pause(not is_paused)


func set_pause(is_paused: bool) -> void:
    var was_paused := self.is_paused
    self.is_paused = is_paused
    
    get_tree().set_pause(is_paused)
    
    if is_paused and current_screen.type == GAME:
        open_screen(PAUSE)
    elif was_paused and current_screen.type == PAUSE:
        open_screen(GAME)


func open_screen(screen_type: int) -> void:
    if is_instance_valid(current_screen) and \
            current_screen.type == screen_type:
        # The screen is already open.
        return
    
    if is_instance_valid(current_screen) and \
            current_screen.type != GAME:
        # Close the previous screen.
        print("Closing previous screen: %s" % \
                get_screen_string(current_screen.type))
        current_screen.queue_free()
    
    print("Opening next screen: %s" % \
            get_screen_string(screen_type))
    
    if screen_type == GAME:
        current_screen = game_screen
        game_screen.on_screen_opened()
    else:
        var packed_scene: PackedScene = packed_scenes[screen_type]
        current_screen = packed_scene.instance()
        screen_container.add_child(current_screen)


func set_level(level_type: int) -> void:
    game_screen.set_level(level_type)


static func get_screen_string(screen_type: int) -> String:
    match screen_type:
        CREDITS:
            return "CREDITS"
        GAME:
            return "GAME"
        MAIN_MENU:
            return "MAIN_MENU"
        PAUSE:
            return "PAUSE"
        _:
            push_error("Invalid screen_type")
            return "??"