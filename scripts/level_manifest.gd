class_name LevelManifest
extends Node


enum {
    UNKNOWN = 0,
    DEMO_BASE = 1,
    DEMO_DIEGO = 2,
    DEMO_LEVI = 3,
    DEMO_ZAVEN = 4,
    TUTORIAL = 5,
    FLING = 6,
    VERTICAL = 7,
}

var packed_scenes := {
    DEMO_BASE: load("res://scenes/demos/demo_base.tscn"),
    DEMO_DIEGO: load("res://scenes/demos/demo_diego.tscn"),
    DEMO_LEVI: load("res://scenes/demos/demo_levi.tscn"),
    DEMO_ZAVEN: load("res://scenes/demos/demo_zaven.tscn"),
    TUTORIAL: load("res://scenes/levels/tutorial_level.tscn"),
    FLING: load("res://scenes/levels/fling_level.tscn"),
    VERTICAL: load("res://scenes/levels/vertical_level.tscn")
}

const START_LEVEL := DEMO_BASE


static func get_level_string(level_type: int) -> String:
    match level_type:
        DEMO_BASE:
            return "DEMO_BASE"
        DEMO_DIEGO:
            return "DEMO_DIEGO"
        DEMO_LEVI:
            return "DEMO_LEVI"
        DEMO_ZAVEN:
            return "DEMO_ZAVEN"
        _:
            push_error("Invalid level_type")
            return "??"
