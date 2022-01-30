tool
class_name GameScreen
extends Screen


var level_type := -1
var level
var level_logic: LevelLogic


func _init().(ScreenController.GAME, PAUSE_MODE_STOP) -> void:
    pass


func _ready() -> void:
    pass


func set_level(level_type: int) -> void:
    if is_instance_valid(level) and \
            self.level_type == level_type:
        # We're already on this level.
        return
    
    if is_instance_valid(level):
        # Destroy any previous level.
        level.queue_free()
    
    self.level_type = level_type
    level = levels.packed_scenes[level_type].instance()
    add_child(level)
    
    level_logic = _get_level_logic(level)
    
    print("set_level: %s" % LevelManifest.get_level_string(level_type))


func _get_level_logic(level) -> LevelLogic:
    if !is_instance_valid(level):
        return null
    var all_level_logics := get_tree().get_nodes_in_group("level")
    var level_logics_in_level := []
    for level_logic in all_level_logics:
        if level.is_a_parent_of(level_logic):
            level_logics_in_level.push_back(level_logic)
    assert(level_logics_in_level.size() == 1)
    return level_logics_in_level[0]


func on_screen_opened() -> void:
    screen.set_pause(false)
