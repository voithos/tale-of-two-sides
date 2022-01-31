class_name ScreenController
extends Node


enum {
    CREDITS,
    GAME,
    MAIN_MENU,
    PAUSE,
    INTRO_STORY,
    END_STORY,
}

var packed_scenes := {
    CREDITS: load("res://scenes/screens/credits_screen.tscn"),
    GAME: load("res://scenes/screens/game_screen.tscn"),
    MAIN_MENU: load("res://scenes/screens/main_menu_screen.tscn"),
    PAUSE: load("res://scenes/screens/pause_screen.tscn"),
    INTRO_STORY: load("res://scenes/screens/intro_story_screen.tscn"),
    END_STORY: load("res://scenes/screens/end_story_screen.tscn"),
}

const FORCES_FULLSCREEN := false

var is_paused := false

var screen_container: CanvasLayer
var game_screen
var current_screen


func _ready():
    set_pause_mode(PAUSE_MODE_PROCESS) # Never pause this node.
    if not OS.is_debug_build() or \
            FORCES_FULLSCREEN:
        OS.set_window_fullscreen(true)
    
    screen_container = CanvasLayer.new()
    add_child(screen_container)
    
    game_screen = packed_scenes[GAME].instance()
    add_child(game_screen)


func _input(event):
    if event is InputEventKey and event.is_pressed():
        if event.scancode == KEY_ESCAPE:
            if OS.is_debug_build() and \
                    not OS.has_feature("HTML5"):
                close_app()
            else:
                set_pause(not is_paused)
        
        if event.scancode == KEY_F11:
            OS.window_fullscreen = not OS.window_fullscreen
    
    if Input.is_action_just_pressed("pause"):
        set_pause(not is_paused)
    
    if Input.is_action_just_pressed("reset"):
        print("Resetting level")
        game_screen.level_logic.reset()


func _notification(notification: int) -> void:
    pass
    # Pause when the window loses focus.
#    match notification:
#        MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#            set_pause(true)
#        MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#            _on_app_close()


func close_app() -> void:
    _on_app_close()
    get_tree().quit()


func _on_app_close() -> void:
    if screenshot.was_screenshot_taken:
        screenshot.open_screenshot_folder()


func set_pause(is_paused: bool) -> void:
    var was_paused := self.is_paused
    self.is_paused = is_paused
    
    get_tree().set_pause(is_paused)
    
    if is_instance_valid(current_screen):
        if is_paused and current_screen.type == GAME:
            print("Pausing")
            open_screen(PAUSE)
        elif was_paused and current_screen.type == PAUSE:
            print("Unpausing")
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


func reset_level() -> void:
    game_screen.reset_level()


func on_level_complete() -> void:
    game_screen.level_logic.on_level_complete()


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
        INTRO_STORY:
            return "INTRO_STORY"
        END_STORY:
            return "END_STORY"
        _:
            push_error("Invalid screen_type")
            return "??"
