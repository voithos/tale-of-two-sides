class_name LevelLogic
extends Node2D


const NEXT_LEVEL_TIMEOUT = 1 # Seconds

# Note, this has no type hint because of https://github.com/godotengine/godot/issues/52140. :\
export var next_level := LevelManifest.UNKNOWN
export var background_music := Music.PHASE_UP

func _ready() -> void:
    music.play(background_music)

func on_level_complete() -> void:
    if next_level != LevelManifest.UNKNOWN:
        _begin_next_level_transition()
    else:
        screen.open_screen(ScreenController.CREDITS)

func _begin_next_level_transition():
    var timer = Timer.new()
    add_child(timer)
    timer.connect("timeout", self, "_delayed_begin_next_level_transition")
    timer.wait_time = NEXT_LEVEL_TIMEOUT
    timer.one_shot = true
    timer.start()

func _delayed_begin_next_level_transition():
    var transition = get_tree().get_nodes_in_group("transition")[0]
    transition.connect("fade_complete", self, "_load_next_level")
    transition.begin_fade()

func reset():
    var transition = get_tree().get_nodes_in_group("transition")[0]
    transition.connect("fade_complete", self, "_reset_level")
    transition.begin_fade()

func _load_next_level():
    assert(next_level != LevelManifest.UNKNOWN)
    progression_store.complete_current_level()
    screen.set_level(next_level)

func _reset_level():
    screen.reset_level()
