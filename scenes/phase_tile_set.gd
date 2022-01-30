tool
class_name PhaseTileSet
extends TileSet


const BOUND_TILES := {
    "collidable_tiles": true,
    "angled_tiles": true,
}


func _is_tile_bound(
        drawn_id: int,
        neighbor_id: int) -> bool:
    print(".>>>>>")
    if neighbor_id == TileMap.INVALID_CELL:
        return false
    return BOUND_TILES.has(tile_get_name(drawn_id)) and \
            BOUND_TILES.has(tile_get_name(neighbor_id))
