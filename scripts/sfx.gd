class_name Sfx
extends Node

# Centralized SFX management.

const SFX_DB = -22.0
const EXTRA_LOUD_DB = -6.0
const LOUD_DB = -12.0
const QUIET_DB = -25.0
const BACKGROUND_QUIET_DB = -40.0

# Preloaded sound effects.
# ========================
enum {
    BUTTON_PRESS,
    CADENCE_FAILURE,
    CADENCE_SUCCESS,
    CONTACT,
    CONTACT2,
    JUMP,
    JUMP_OLD,
    LAND,
    PHASE,
    PHASE2,
    PICKUP_CRYSTAL,
    PICKUP_CRYSTAL2,
    SCHISM,
}

const SAMPLES = {
    # TODO: Add a new button sound.
    BUTTON_PRESS: preload("res://assets/sfx/pickup_crystal.wav"),
    CADENCE_FAILURE: preload("res://assets/sfx/cadence_failure.wav"),
    CADENCE_SUCCESS: preload("res://assets/sfx/cadence_success.wav"),
    CONTACT: preload("res://assets/sfx/contact.wav"),
    CONTACT2: preload("res://assets/sfx/contact2.wav"),
    JUMP: preload("res://assets/sfx/jump.wav"),
    JUMP_OLD: preload("res://assets/sfx/jump_old.wav"),
    LAND: preload("res://assets/sfx/land.wav"),
    PHASE: preload("res://assets/sfx/phase.wav"),
    PHASE2: preload("res://assets/sfx/phase2.wav"),
    PICKUP_CRYSTAL: preload("res://assets/sfx/pickup_crystal.wav"),
    PICKUP_CRYSTAL2: preload("res://assets/sfx/pickup_crystal2.wav"),
    SCHISM: preload("res://assets/sfx/schism.wav"),
}
# ========================

# Max number of simultaneously-playing sfx.
const POOL_SIZE = 8
var pool = []
# Index of the current audio player in the pool.
var next_player = 0

var timer: Timer

func _ready():
    _init_stream_players()
    timer = Timer.new()
    add_child(timer)
    timer.connect("timeout", self, "_reset_music_volume")

func _init_stream_players():
    # warning-ignore:unused_variable
    for i in range(POOL_SIZE):
        var player = AudioStreamPlayer.new()
        add_child(player)
        pool.append(player)

func _get_next_player_idx():
    var next = next_player
    next_player = (next_player + 1) % POOL_SIZE
    return next

func play(sample, db=SFX_DB):
    var idx = _get_next_player_idx()
    var player = pool[idx]
    play_with_player(player, sample, db)

# Use this with an audio player that exists in the scene.
func play_with_player(player, sample, db=SFX_DB):
    assert(sample in SAMPLES)
    var stream = SAMPLES[sample]
    player.stream = stream
    player.volume_db = db
    player.play()

func play_cadence(is_success: bool) -> void:
    music.last_musicbox.set_volume_db(Music.MOSTLY_MUTED_DB)
    
    timer.stop()
    timer.wait_time = 2.0
    timer.one_shot = true
    timer.start()
    
    var sfx_type := \
            CADENCE_SUCCESS if \
            is_success else \
            CADENCE_FAILURE
    play(sfx_type, EXTRA_LOUD_DB)

func _reset_music_volume() -> void:
    music.last_musicbox.set_volume_db(Music.MUSIC_DB)
