class_name PhaseTileMap
extends TileMap


const _MODULATION_DURATION := 0.6

const _MIN_FLOOR_SATURATION := 0.1
const _MAX_FLOOR_SATURATION := 1.0
const _MIN_CEILING_SATURATION := 0.35
const _MAX_CEILING_SATURATION := 1.0

var is_walking_on_floors := true
var _tween: Tween


func _ready() -> void:
    _tween = Tween.new()
    add_child(_tween)
    
    _interpolate_phase(1.0)


func set_phase_mode(is_walking_on_floors: bool) -> void:
    var is_changed := self.is_walking_on_floors != is_walking_on_floors
    if is_changed:
        self.is_walking_on_floors = is_walking_on_floors
        _tween.stop_all()
        _tween.interpolate_method(
                self,
                "_interpolate_phase",
                0.0,
                1.0,
                _MODULATION_DURATION,
                Tween.TRANS_QUAD,
                Tween.EASE_IN_OUT,
                0.0)
        _tween.start()


func _interpolate_phase(progress: float) -> void:
    var floor_saturation_progress := \
            progress if \
            is_walking_on_floors else \
            1.0 - progress
    var floor_saturation: float = lerp(
            _MIN_FLOOR_SATURATION,
            _MAX_FLOOR_SATURATION,
            floor_saturation_progress)
    var ceiling_saturation: float = lerp(
            _MIN_CEILING_SATURATION,
            _MAX_CEILING_SATURATION,
            1.0 - floor_saturation_progress)
    material.set_shader_param("floor_saturation", floor_saturation)
    material.set_shader_param("ceiling_saturation", ceiling_saturation)
