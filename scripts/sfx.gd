class_name Sfx
extends Node

# Centralized SFX management.

const SFX_DB = -22.0
const LOUD_DB = -12.0
const QUIET_DB = -25.0
const BACKGROUND_QUIET_DB = -40.0

# Preloaded sound effects.
# ========================
enum {
    # TODO: Replace with actual sounds
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

func _ready():
    _init_stream_players()

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
