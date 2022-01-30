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


func _begin_next_level_transition() -> void:
    var timer = Timer.new()
    add_child(timer)
    timer.connect("timeout", self, "_delayed_begin_next_level_transition")
    timer.wait_time = NEXT_LEVEL_TIMEOUT
    timer.one_shot = true
    timer.start()


func _delayed_begin_next_level_transition() -> void:
    var transition = get_tree().get_nodes_in_group("transition")[0]
    transition.connect("fade_complete", self, "_load_next_level")
    transition.begin_fade()


func reset() -> void:
    var transition = get_tree().get_nodes_in_group("transition")[0]
    transition.connect("fade_complete", self, "_reset_level")
    transition.begin_fade()


func _load_next_level() -> void:
    assert(next_level != LevelManifest.UNKNOWN)
    progression_store.complete_current_level()
    screen.set_level(next_level)


func _reset_level() -> void:
    screen.reset_level()


func get_combined_tile_map_region() -> Rect2:
    var tile_maps := get_tree().get_nodes_in_group("tiles")
    assert(!tile_maps.empty())
    var tile_map: TileMap = tile_maps[0]
    var tile_map_region := get_tile_map_bounds_in_world_coordinates(tile_map)
    for i in range(1, tile_maps.size()):
        tile_map = tile_maps[i]
        tile_map_region = tile_map_region.merge(
                get_tile_map_bounds_in_world_coordinates(tile_map))
    return tile_map_region


static func get_tile_map_bounds_in_world_coordinates(
        tile_map: TileMap) -> Rect2:
    var used_rect := tile_map.get_used_rect()
    var cell_size := tile_map.cell_size
    return Rect2(
            used_rect.position.x * cell_size.x,
            used_rect.position.y * cell_size.y,
            used_rect.size.x * cell_size.x,
            used_rect.size.y * cell_size.y)
